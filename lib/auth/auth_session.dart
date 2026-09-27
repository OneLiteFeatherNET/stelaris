import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:oidc/oidc.dart';
import 'package:oidc_default_store/oidc_default_store.dart';
import 'package:stelaris/auth/auth_config.dart';
import 'package:stelaris/auth/auth_state.dart';
import 'package:stelaris/auth/claim_source.dart';
import 'package:stelaris/auth/provider_support.dart';
import 'package:stelaris/auth/role_mapper.dart';
import 'package:stelaris/auth/token_source.dart';

/// The signed-in person, and everything it takes to get and keep one.
///
/// One instance for the process, created only when a deployment configured a
/// provider. Everything provider-specific comes from the issuer's discovery
/// document; nothing here knows which product is on the other end.
///
/// Tokens live in the store this holds and leave it only as the bearer header
/// [accessToken] hands to the API client. What the interface sees is [state],
/// which carries facts and no credentials.
class AuthSession implements TokenSource {
  AuthSession({
    required this.config,
    required Uri baseHref,
    OidcStore? store,
  }) : _baseHref = asDirectory(baseHref),
       _store = store ?? OidcDefaultStore(),
      _roles = RoleMapper(
        paths: config.roleClaims,
        sources: config.roleClaimsSource,
        aliases: config.roleAliases,
      );

  /// The deployment's base href - where the bundle is served from, not the
  /// page currently open.
  ///
  /// It has to be the base: the redirect URI is registered with the provider
  /// and has to come out the same every time, and resolving `redirect.html`
  /// against a page URL would make it depend on the route somebody happened to
  /// deep-link into. Taken from the document rather than configured, so a
  /// deployment under a sub path, a staging host and a local `flutter run` all
  /// produce the right redirect with nobody maintaining a list.
  final Uri _baseHref;

  /// A base href always denotes a directory, so make sure it reads as one -
  /// `https://host/ui` and `https://host/ui/` have to resolve alike.
  @visibleForTesting
  static Uri asDirectory(Uri base) =>
      base.path.endsWith('/') ? base : base.replace(path: '${base.path}/');

  final AuthConfig config;

  /// Where the tokens live. Never [AppState]: that is serialised into browser
  /// storage in full, and this keeps them out of the document it produces.
  final OidcStore _store;
  final RoleMapper _roles;

  final StreamController<AuthState> _states =
      StreamController<AuthState>.broadcast();

  OidcUserManager? _manager;
  StreamSubscription<OidcUser?>? _users;

  AuthState _state = const AuthState(status: AuthStatus.initialising);

  /// What the interface is allowed to know right now.
  AuthState get state => _state;

  /// Every change to [state], for the store to mirror into [AppState].
  Stream<AuthState> get states => _states.stream;

  /// Where the provider sends the browser back to, for sign-in and sign-out
  /// alike. A real page in the bundle, not a route: it runs before Flutter
  /// does and hands the response to the app.
  Uri get redirectUri => _baseHref.resolve('redirect.html');

  /// Brings up the session: reads the discovery document, restores whatever
  /// the store still holds, and finishes a redirect that is coming back in.
  ///
  /// Never throws. A provider that cannot be reached or cannot do this flow
  /// leaves the session [AuthStatus.unavailable], which the interface offers to
  /// retry. Falling back to running unauthenticated would turn a broken
  /// provider into a silently unprotected deployment.
  Future<void> init() async {
    final OidcUserManager manager = _manager ??= OidcUserManager.lazy(
      discoveryDocumentUri: OidcUtils.getOpenIdConfigWellKnownUri(
        config.issuer,
      ),
      // No secret: a bundle the browser downloads cannot keep one, which is
      // what makes PKCE load-bearing rather than belt and braces.
      clientCredentials: OidcClientAuthentication.none(
        clientId: config.clientId,
      ),
      store: _store,
      settings: buildSettings(config, _baseHref),
    );

    try {
      await manager.init();

      final String? unsupported = ProviderSupport.unsupportedReason(
        manager.discoveryDocument,
      );
      if (unsupported != null) {
        debugPrint(unsupported);
        _emit(const AuthState(status: AuthStatus.unavailable));
        return;
      }

      _users = manager.userChanges().listen(_onUser);
      _onUser(manager.currentUser);
      // Anything at all: a provider that is unreachable, a document that does
      // not parse, a clock too far off to accept a token. They differ only in
      // the log line; none of them may end with the app deciding to run
      // without authentication.
    } catch (error) {
      debugPrint('Could not reach the identity provider at ${config.issuer}: '
          '$error');
      _emit(const AuthState(status: AuthStatus.unavailable));
    }
  }

  /// Sends the browser to the provider. Returns when the redirect is under way,
  /// not when somebody has signed in - the page is gone by then.
  ///
  /// [returnTo] is the app route to come back to, as go_router writes it
  /// (`/items/detail`). Absent, the app's entry point. Resolving it here rather
  /// than at the call site keeps the sub path arithmetic in one place.
  Future<void> signIn({String? returnTo}) async {
    final OidcUserManager? manager = _manager;
    if (manager == null) {
      return;
    }
    try {
      await manager.loginAuthorizationCodeFlow(
        originalUri: returnUriFor(returnTo),
      );
    } catch (error) {
      debugPrint('Sign-in could not be started: $error');
      _emit(const AuthState(status: AuthStatus.unavailable));
    }
  }

  /// Ends the local session and the provider's.
  ///
  /// The local side goes first and unconditionally: if the provider's
  /// end-session endpoint is unreachable, the person still has to end up signed
  /// out here rather than staying signed in because a remote call failed.
  Future<void> signOut() async {
    final OidcUserManager? manager = _manager;
    _emit(const AuthState(status: AuthStatus.signedOut));
    if (manager == null) {
      return;
    }
    try {
      // The package sends id_token_hint from the user it is forgetting.
      // Keycloak has required it since 18; providers that do not want it
      // ignore it, so there is one path rather than two.
      await manager.logout(originalUri: _baseHref);
    } catch (error) {
      debugPrint('The provider session could not be ended: $error');
    }
  }

  /// Where to come back to after signing in.
  ///
  /// A go_router location is written from the app's root (`/items`), while the
  /// deployment may sit under a prefix (`/ui/`). Stripping the leading slash is
  /// what makes the two compose: `/ui/` resolving `items` is `/ui/items`, while
  /// resolving `/items` would land on the host root, outside the app.
  @visibleForTesting
  Uri returnUriFor(String? location) {
    if (location == null || location.isEmpty || location == '/') {
      return _baseHref;
    }
    final String relative = location.startsWith('/')
        ? location.substring(1)
        : location;
    return _baseHref.resolve(relative);
  }

  /// The bearer credential for a backend call, or null when there is none.
  @override
  String? get accessToken => _manager?.currentUser?.token.accessToken;

  /// Renews the session and returns whether a usable token came back.
  ///
  /// Called by the API client when the backend refuses a request. A provider
  /// that rotates refresh tokens invalidates the session if one is presented
  /// twice, so the client is responsible for never calling this concurrently -
  /// see the queued interceptor in `ApiClient`.
  @override
  Future<bool> refresh() async {
    final OidcUserManager? manager = _manager;
    if (manager == null || manager.currentUser == null) {
      return false;
    }
    try {
      final OidcUser? user = await manager.refreshToken();
      if (user == null) {
        _emit(const AuthState(status: AuthStatus.expired));
        return false;
      }
      return true;
    } catch (error) {
      debugPrint('The session could not be renewed: $error');
      _emit(const AuthState(status: AuthStatus.expired));
      return false;
    }
  }

  Future<void> dispose() async {
    await _users?.cancel();
    await _states.close();
    _manager?.dispose();
  }

  void _onUser(OidcUser? user) {
    if (user == null) {
      // Expiry has already been reported by whoever noticed it; do not
      // overwrite it with a plain sign-out, or the interface loses the only
      // chance it had to say why the session ended.
      if (_state.status != AuthStatus.expired) {
        _emit(const AuthState(status: AuthStatus.signedOut));
      }
      return;
    }
    _emit(
      AuthState(
        status: AuthStatus.signedIn,
        displayName: _displayNameOf(user),
        roles: _roles.rolesFrom(claimsOf(user)),
      ),
    );
  }

  /// The three claim sets a provider can put roles in.
  ///
  /// The access token is parsed, never verified: these claims decide what the
  /// interface offers and nothing else, and the backend validates the same
  /// token before it permits anything. A provider that issues an opaque access
  /// token contributes an empty set here and the others are still read.
  @visibleForTesting
  static TokenClaims claimsOf(OidcUser user) => TokenClaims(
    accessToken: TokenClaims.decode(user.token.accessToken),
    idToken: user.claims.toJson(),
    userInfo: user.userInfo,
  );

  /// A name to show, from whichever claim the provider filled in.
  ///
  /// None of these is guaranteed, so the interface has to work without one.
  static String? _displayNameOf(OidcUser user) {
    final Map<String, dynamic> claims = <String, dynamic>{
      ...user.claims.toJson(),
      ...user.userInfo,
    };
    for (final String key in const ['name', 'preferred_username', 'email']) {
      final Object? value = claims[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  void _emit(AuthState next) {
    if (_state == next) {
      return;
    }
    _state = next;
    if (!_states.isClosed) {
      _states.add(next);
    }
  }

  /// The settings the manager runs with, exposed so they can be asserted
  /// without a browser.
  @visibleForTesting
  static OidcUserManagerSettings buildSettings(AuthConfig config, Uri baseHref) {
    final Uri redirect = asDirectory(baseHref).resolve('redirect.html');
    return OidcUserManagerSettings(
      redirectUri: redirect,
      postLogoutRedirectUri: redirect,
      frontChannelLogoutUri: redirect.replace(
        queryParameters: <String, String>{
          ...redirect.queryParameters,
          'requestType': 'front-channel-logout',
        },
      ),
      scope: config.scopes,
      // Some providers want the audience named as an authorization parameter;
      // the ones that do not ignore it, so this stays one code path.
      extraAuthenticationParameters: config.audience == null
          ? null
          : <String, dynamic>{'audience': config.audience},
      options: const OidcPlatformSpecificOptions(
        web: OidcPlatformSpecificOptions_Web(
          // Not the package's recommended newPage, and not popup or
          // hiddenIFrame. Sign-in is started by the route guard as often as by
          // a button - a deep link from an unauthenticated person, a session
          // that expired while the tab sat open - and neither has a user
          // gesture behind it, so a browser blocks the tab or popup and the
          // person sees nothing happen. A same-page navigation always works.
          // Losing the in-memory UI state is the price, and the reason the
          // originally requested route is restored afterwards.
          navigationMode:
              OidcPlatformSpecificOptions_Web_NavigationMode.samePage,
        ),
      ),
    );
  }
}
