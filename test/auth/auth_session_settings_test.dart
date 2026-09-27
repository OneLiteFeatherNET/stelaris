import 'package:flutter_test/flutter_test.dart';
import 'package:oidc/oidc.dart';
import 'package:stelaris/auth/auth_config.dart';
import 'package:stelaris/auth/auth_session.dart';
import 'package:stelaris/auth/auth_state.dart';

AuthConfig configWith({String? audience}) => AuthConfig(
  issuer: Uri.parse('https://idp.example/realms/stelaris'),
  clientId: 'stelaris-ui',
  scopes: const ['openid', 'profile', 'offline_access'],
  audience: audience,
  roleClaims: AuthConfig.defaultRoleClaimsFor('stelaris-ui'),
  roleClaimsSource: AuthConfig.defaultRoleClaimsSource,
);

void main() {
  group('AuthSession.buildSettings', () {
    final Uri appBase = Uri.parse('https://stelaris.example/');

    test('redirects to the page in the bundle, not to a route', () {
      // A go_router route cannot take the redirect: it only exists once Flutter
      // has booted, and the response arrives before that.
      final settings = AuthSession.buildSettings(configWith(), appBase);

      expect(settings.redirectUri, Uri.parse('https://stelaris.example/redirect.html'));
      expect(settings.postLogoutRedirectUri, settings.redirectUri);
    });

    test('resolves the redirect against a sub path deployment', () {
      // The chart can put the app under a prefix; a redirect hardcoded to the
      // host root would then be registered wrong in every such environment.
      final settings = AuthSession.buildSettings(
        configWith(),
        Uri.parse('https://stelaris.example/ui/'),
      );

      expect(
        settings.redirectUri,
        Uri.parse('https://stelaris.example/ui/redirect.html'),
      );
    });

    test('treats a base href without a trailing slash as a directory', () {
      final settings = AuthSession.buildSettings(
        configWith(),
        Uri.parse('https://stelaris.example/ui'),
      );

      expect(
        settings.redirectUri,
        Uri.parse('https://stelaris.example/ui/redirect.html'),
      );
    });

    test('marks the front channel logout uri so the page can tell them apart', () {
      final settings = AuthSession.buildSettings(configWith(), appBase);

      expect(
        settings.frontChannelLogoutUri!.queryParameters['requestType'],
        'front-channel-logout',
      );
    });

    test('requests exactly the configured scopes', () {
      final settings = AuthSession.buildSettings(configWith(), appBase);

      expect(settings.scope, ['openid', 'profile', 'offline_access']);
    });

    test('sends no audience when none is configured', () {
      final settings = AuthSession.buildSettings(configWith(), appBase);

      expect(settings.extraAuthenticationParameters, isNull);
    });

    test('names the audience when one is configured', () {
      final settings = AuthSession.buildSettings(
        configWith(audience: 'stelaris-backend'),
        appBase,
      );

      expect(
        settings.extraAuthenticationParameters,
        containsPair('audience', 'stelaris-backend'),
      );
    });

    test('navigates on the same page, never in a frame or a popup', () {
      // The guard starts sign-in for a deep link and for an expired session,
      // neither of which has a user gesture behind it - a browser blocks a tab
      // or popup opened without one, and a hidden frame needs the third-party
      // cookies browsers no longer send.
      final settings = AuthSession.buildSettings(configWith(), appBase);

      expect(
        settings.options!.web.navigationMode,
        OidcPlatformSpecificOptions_Web_NavigationMode.samePage,
      );
    });
  });

  group('AuthSession before it is initialised', () {
    final Uri appBaseHref = Uri.parse('https://stelaris.example/');

    test('starts out initialising, not signed out', () {
      // Claiming signed-out before the store has been read would flash the
      // sign-in screen at somebody who has a perfectly good session.
      final session = AuthSession(config: configWith(), baseHref: appBaseHref);

      expect(session.state.status, AuthStatus.initialising);
      expect(session.accessToken, isNull);
    });

    test('resolves its redirect from the base href, not the open page', () {
      // Regression: resolving against the current page made the redirect uri
      // depend on the route somebody deep-linked into, so a person arriving at
      // /items/detail was sent to /items/redirect.html - an address no
      // provider has been told about.
      final session = AuthSession(
        config: configWith(),
        baseHref: Uri.parse('https://stelaris.example/ui/'),
      );

      expect(
        session.redirectUri,
        Uri.parse('https://stelaris.example/ui/redirect.html'),
      );
    });

    test('signing out ends the local session even with no provider reached', () {
      // The local side is unconditional: a person who asked to sign out must
      // not stay signed in because a remote call could not be made.
      final session = AuthSession(config: configWith(), baseHref: appBaseHref);

      expect(
        session.states,
        emits(
          predicate<AuthState>((s) => s.status == AuthStatus.signedOut),
        ),
      );

      session.signOut();
    });

    test('renewal reports failure rather than throwing when there is no session',
        () async {
      final session = AuthSession(config: configWith(), baseHref: appBaseHref);

      expect(await session.refresh(), isFalse);
    });
  });
}
