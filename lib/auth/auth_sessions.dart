import 'package:flutter/foundation.dart';
import 'package:stelaris/auth/auth_config.dart';
import 'package:stelaris/auth/auth_session.dart';
import 'package:stelaris/env/runtime_config.dart';

/// The one session for the process, or none.
///
/// A singleton because this project wires its collaborators that way already -
/// `ApiService` is one - and because a second session would mean a second set
/// of tokens racing the first one's renewal, which providers that rotate
/// refresh tokens answer by ending the session.
///
/// Null is the ordinary state, not a failure: it is exactly what a deployment
/// that configured no provider looks like, and every caller has to read it that
/// way rather than as something having gone wrong.
abstract final class AuthSessions {
  static AuthSession? _current;

  /// The session, or null in a deployment with no identity provider.
  static AuthSession? get current => _current;

  /// Brings the session up, if there is one to bring up.
  ///
  /// Reads [RuntimeConfig], so it runs after the configuration is loaded and
  /// before anything can ask whether somebody is signed in. With no `auth`
  /// block it does nothing whatsoever: no session, no store read, and no
  /// request to any provider - which is what keeps an unauthenticated
  /// deployment, and a local `flutter run`, working exactly as before.
  ///
  /// [baseHref] is the deployment's base, which the redirect URI resolves
  /// against. It comes from the document rather than from configuration, so a
  /// sub path deployment needs no extra setting.
  static Future<void> start({
    required Uri baseHref,
    AuthConfig? config,
  }) async {
    final AuthConfig? auth = config ?? RuntimeConfig.current.auth;
    if (auth == null) {
      _current = null;
      return;
    }
    final AuthSession session = AuthSession(config: auth, baseHref: baseHref);
    _current = session;
    await session.init();
  }

  @visibleForTesting
  static void reset() => _current = null;
}
