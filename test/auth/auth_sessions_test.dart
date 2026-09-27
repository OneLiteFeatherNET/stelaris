import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/auth/auth_config.dart';
import 'package:stelaris/auth/auth_sessions.dart';
import 'package:stelaris/env/runtime_config.dart';

void main() {
  setUp(() {
    RuntimeConfig.reset();
    AuthSessions.reset();
  });
  tearDown(AuthSessions.reset);

  final Uri baseHref = Uri.parse('https://stelaris.example/');

  group('AuthSessions.start', () {
    test('creates no session when no provider is configured', () async {
      // The rollout gate. Nothing is constructed, so nothing can reach a
      // provider, read a store, or put a sign-in screen in front of anybody.
      await AuthSessions.start(baseHref: baseHref);

      expect(AuthSessions.current, isNull);
    });

    test('starting twice without a provider stays at no session', () async {
      await AuthSessions.start(baseHref: baseHref);
      await AuthSessions.start(baseHref: baseHref);

      expect(AuthSessions.current, isNull);
    });

    test('reads the configuration rather than being told', () async {
      // RuntimeConfig is the single source; a caller passing its own config is
      // a test seam, not a second way to configure the app.
      expect(RuntimeConfig.current.auth, isNull);

      await AuthSessions.start(baseHref: baseHref);

      expect(AuthSessions.current, isNull);
    });

    test('creates a session for a configured provider', () async {
      // init() reaches for the discovery document and fails without a network,
      // which is fine: what matters here is that a session exists at all and
      // carries the configured provider.
      await AuthSessions.start(
        baseHref: baseHref,
        config: AuthConfig(
          issuer: Uri.parse('https://idp.invalid/realms/stelaris'),
          clientId: 'stelaris-ui',
          scopes: const ['openid'],
          roleClaims: AuthConfig.defaultRoleClaimsFor('stelaris-ui'),
          roleClaimsSource: AuthConfig.defaultRoleClaimsSource,
        ),
      );

      expect(AuthSessions.current, isNotNull);
      expect(AuthSessions.current!.config.clientId, 'stelaris-ui');
      expect(
        AuthSessions.current!.redirectUri,
        Uri.parse('https://stelaris.example/redirect.html'),
      );
    });
  });
}
