import 'package:flutter_test/flutter_test.dart';
import 'package:oidc/oidc.dart';
import 'package:stelaris/auth/auth_config.dart';
import 'package:stelaris/auth/auth_session.dart';
import 'package:stelaris/auth/auth_state.dart';

final AuthConfig _config = AuthConfig(
  issuer: Uri.parse('https://idp.example/realms/stelaris'),
  clientId: 'stelaris-ui',
  scopes: const ['openid', 'profile', 'offline_access'],
  roleClaims: AuthConfig.defaultRoleClaimsFor('stelaris-ui'),
  roleClaimsSource: AuthConfig.defaultRoleClaimsSource,
);

const String _registration =
    '${OidcUserManagerBase.clientRegistrationKeyPrefix}https://idp.example';

Future<void> _storeTokens(OidcStore store) => store.setMany(
  OidcStoreNamespace.secureTokens,
  values: const {
    'currentToken': 'a token',
    'code_verifier.abc': 'a verifier',
    _registration: 'a registration',
  },
);

Future<void> _markSignOutPending(OidcStore store) => store.set(
  OidcStoreNamespace.request,
  key: AuthSession.signOutPendingKey,
  value: 'true',
);

Future<Set<String>> _tokens(OidcStore store) =>
    store.getAllKeys(OidcStoreNamespace.secureTokens);

Future<String?> _pending(OidcStore store) =>
    store.get(OidcStoreNamespace.request, key: AuthSession.signOutPendingKey);

void main() {
  // The binding answers every request with a 400, so the provider of these
  // tests is one that cannot be reached, and no test waits on the network.
  TestWidgetsFlutterBinding.ensureInitialized();

  late OidcMemoryStore store;
  late AuthSession session;

  setUp(() {
    store = OidcMemoryStore();
    session = AuthSession(
      config: _config,
      baseHref: Uri.parse('https://stelaris.example/'),
      store: store,
    );
  });

  tearDown(() => session.dispose());

  group('a sign-out the provider never confirmed', () {
    test('is finished on the next start, without the provider', () async {
      await _storeTokens(store);
      await _markSignOutPending(store);

      await session.init();

      expect(session.state.status, AuthStatus.unavailable);
      expect(await _tokens(store), {_registration});
      expect(await _pending(store), isNull);
    });

    test('is finished before a new sign-in starts', () async {
      await session.init();
      await _storeTokens(store);
      await _markSignOutPending(store);

      await session.signIn();

      expect(await _tokens(store), {_registration});
      expect(await _pending(store), isNull);
    });
  });

  test('a start without a pending sign-out keeps the tokens', () async {
    await _storeTokens(store);

    await session.init();

    expect(await _tokens(store), hasLength(3));
  });

  test(
    'signing out discards the tokens when the provider cannot be asked',
    () async {
      await session.init();
      await _storeTokens(store);

      await session.signOut();

      expect(session.state.status, AuthStatus.signedOut);
      expect(await _tokens(store), {_registration});
      expect(await _pending(store), isNull);
    },
  );
}
