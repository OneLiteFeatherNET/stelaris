import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/auth/auth_config.dart';
import 'package:stelaris/auth/claim_path.dart';
import 'package:stelaris/auth/claim_source.dart';
import 'package:stelaris/env/runtime_config.dart';

import '../support/fake_http_client_adapter.dart';

/// A [Dio] whose every request is answered by [adapter], so nothing here
/// touches the network.
Dio _dioWith(HttpClientAdapter adapter) => Dio()..httpClientAdapter = adapter;

/// Answers with [body] verbatim, which is how a served config.json arrives.
Dio _dioServing(String body) => _dioWith(
  FakeHttpClientAdapter(
    (_) => ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    ),
  ),
);

/// Fails every request, standing in for a config.json that is not served.
class _FailingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => throw DioException.connectionError(
    requestOptions: options,
    reason: 'no config served',
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  setUp(RuntimeConfig.reset);
  tearDown(RuntimeConfig.reset);

  group('RuntimeConfig.load', () {
    test('adopts the URLs the server provides', () async {
      await RuntimeConfig.load(
        client: _dioServing(
          jsonEncode({
            'backendUrl': 'https://api.stelaris.example',
            'generatorUrl': 'https://generator.stelaris.example',
          }),
        ),
      );

      expect(RuntimeConfig.current.backendUrl, 'https://api.stelaris.example');
      expect(
        RuntimeConfig.current.generatorUrl,
        'https://generator.stelaris.example',
      );
    });

    test('requests a path relative to the base href', () async {
      late final String requestedPath;
      await RuntimeConfig.load(
        client: _dioWith(
          FakeHttpClientAdapter((options) {
            requestedPath = options.path;
            return ResponseBody.fromString('{}', 200);
          }),
        ),
      );

      // A leading slash would break a deployment under a sub path.
      expect(requestedPath, RuntimeConfig.configFileName);
      expect(requestedPath, isNot(startsWith('/')));
    });

    test(
      'keeps the compiled-in value for a field the server leaves blank',
      () async {
        await RuntimeConfig.load(
          client: _dioServing(
            jsonEncode({
              'backendUrl': 'https://api.stelaris.example',
              'generatorUrl': '   ',
            }),
          ),
        );

        expect(
          RuntimeConfig.current.backendUrl,
          'https://api.stelaris.example',
        );
        expect(
          RuntimeConfig.current.generatorUrl,
          RuntimeConfig.compiledIn.generatorUrl,
        );
      },
    );

    test('falls back when nothing is served', () async {
      await RuntimeConfig.load(client: _dioWith(_FailingAdapter()));

      expect(RuntimeConfig.current.backendUrl, RuntimeConfig.compiledIn.backendUrl);
    });

    test('falls back on a malformed body instead of throwing', () async {
      await RuntimeConfig.load(client: _dioServing('not json at all'));

      expect(RuntimeConfig.current.backendUrl, RuntimeConfig.compiledIn.backendUrl);
    });

    test('falls back when the body is JSON but not an object', () async {
      await RuntimeConfig.load(client: _dioServing('["nope"]'));

      expect(RuntimeConfig.current.backendUrl, RuntimeConfig.compiledIn.backendUrl);
    });

    test('falls back on an empty body', () async {
      await RuntimeConfig.load(client: _dioServing('   '));

      expect(RuntimeConfig.current.backendUrl, RuntimeConfig.compiledIn.backendUrl);
    });

    test('ignores a value of the wrong type', () async {
      await RuntimeConfig.load(
        client: _dioServing(jsonEncode({'backendUrl': 42})),
      );

      expect(RuntimeConfig.current.backendUrl, RuntimeConfig.compiledIn.backendUrl);
    });

    test('fetches the document without any credential', () async {
      // The configuration document is served by the app's own web server, not
      // the backend, and it is read before there is a session at all. A token
      // on this request would be one sent to a host nobody authenticated to.
      late final Map<String, dynamic> headers;
      await RuntimeConfig.load(
        client: _dioWith(
          FakeHttpClientAdapter((options) {
            headers = options.headers;
            return ResponseBody.fromString('{}', 200);
          }),
        ),
      );

      expect(
        headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('authorization')),
      );
    });

    test('leaves auth unset when the document carries no block', () async {
      await RuntimeConfig.load(
        client: _dioServing(
          jsonEncode({'backendUrl': 'https://api.stelaris.example'}),
        ),
      );

      // The whole rollout gate: a document that predates authentication has to
      // keep producing a deployment that does not authenticate.
      expect(RuntimeConfig.current.auth, isNull);
      expect(RuntimeConfig.current.backendUrl, 'https://api.stelaris.example');
    });
  });

  group('RuntimeConfig.load - the auth block', () {
    Future<void> loadAuth(Object? auth) => RuntimeConfig.load(
      client: _dioServing(
        jsonEncode({'backendUrl': 'https://api.stelaris.example', 'auth': auth}),
      ),
    );

    test('adopts a complete block', () async {
      await loadAuth({
        'issuer': 'https://idp.example/realms/stelaris',
        'clientId': 'stelaris-ui',
        'scopes': ['openid', 'profile'],
      });

      final AuthConfig auth = RuntimeConfig.current.auth!;
      expect(auth.issuer, Uri.parse('https://idp.example/realms/stelaris'));
      expect(auth.clientId, 'stelaris-ui');
      expect(auth.scopes, ['openid', 'profile']);
      expect(auth.audience, isNull);
    });

    test('adopts a tenant-shaped issuer the same way', () async {
      // Nothing branches on the provider; this is the previous test against a
      // different issuer shape, and it has to read identically.
      await loadAuth({
        'issuer': 'https://login.microsoftonline.com/contoso/v2.0',
        'clientId': '00000000-0000-0000-0000-000000000000',
        'scopes': ['openid', 'api://an-api/access_as_user'],
      });

      final AuthConfig auth = RuntimeConfig.current.auth!;
      expect(auth.issuer.host, 'login.microsoftonline.com');
      expect(auth.scopes, contains('api://an-api/access_as_user'));
    });

    test('keeps an audience when one is named', () async {
      await loadAuth({
        'issuer': 'https://idp.example/realms/stelaris',
        'clientId': 'stelaris-ui',
        'scopes': ['openid'],
        'audience': '  stelaris-backend  ',
      });

      expect(RuntimeConfig.current.auth!.audience, 'stelaris-backend');
    });

    test('discards a block with no issuer', () async {
      await loadAuth({
        'clientId': 'stelaris-ui',
        'scopes': ['openid'],
      });

      expect(RuntimeConfig.current.auth, isNull);
    });

    test('discards a block with no client id', () async {
      await loadAuth({
        'issuer': 'https://idp.example/realms/stelaris',
        'scopes': ['openid'],
      });

      expect(RuntimeConfig.current.auth, isNull);
    });

    test('discards a block that names no scope', () async {
      await loadAuth({
        'issuer': 'https://idp.example/realms/stelaris',
        'clientId': 'stelaris-ui',
        'scopes': <String>[],
      });

      expect(RuntimeConfig.current.auth, isNull);
    });

    test('discards a block whose scopes are not strings', () async {
      await loadAuth({
        'issuer': 'https://idp.example/realms/stelaris',
        'clientId': 'stelaris-ui',
        'scopes': [1, 2],
      });

      expect(RuntimeConfig.current.auth, isNull);
    });

    test('discards a block whose issuer is not an absolute URL', () async {
      await loadAuth({
        'issuer': 'realms/stelaris',
        'clientId': 'stelaris-ui',
        'scopes': ['openid'],
      });

      expect(RuntimeConfig.current.auth, isNull);
    });

    test('discards a block that is not an object', () async {
      await loadAuth('https://idp.example');

      expect(RuntimeConfig.current.auth, isNull);
    });

    test('discards a block whose fields are blank', () async {
      await loadAuth({'issuer': '   ', 'clientId': '  ', 'scopes': ['  ']});

      expect(RuntimeConfig.current.auth, isNull);
    });

    test('an incomplete block does not disturb the rest of the document',
        () async {
      await loadAuth({'issuer': 'https://idp.example'});

      expect(RuntimeConfig.current.auth, isNull);
      expect(RuntimeConfig.current.backendUrl, 'https://api.stelaris.example');
    });
  });

  group('RuntimeConfig.load - role claim sources', () {
    Future<void> loadSources(Object? sources) => RuntimeConfig.load(
      client: _dioServing(
        jsonEncode({
          'auth': {
            'issuer': 'https://idp.example/realms/stelaris',
            'clientId': 'stelaris-ui',
            'scopes': ['openid'],
            'roleClaimsSource': ?sources,
          },
        }),
      ),
    );

    test('searches every source when none is named', () async {
      await loadSources(null);

      expect(
        RuntimeConfig.current.auth!.roleClaimsSource,
        AuthConfig.defaultRoleClaimsSource,
      );
    });

    test('keeps the named sources, in the order they were named', () async {
      await loadSources(['userInfo', 'accessToken']);

      expect(RuntimeConfig.current.auth!.roleClaimsSource, [
        ClaimSource.userInfo,
        ClaimSource.accessToken,
      ]);
    });

    test('matches a source name regardless of case', () async {
      // It is written by hand into a Secret; insisting on camelCase there buys
      // nothing but a support question.
      await loadSources(['ACCESSTOKEN', '  idtoken  ']);

      expect(RuntimeConfig.current.auth!.roleClaimsSource, [
        ClaimSource.accessToken,
        ClaimSource.idToken,
      ]);
    });

    test('names a source only once however often it appears', () async {
      await loadSources(['idToken', 'idToken']);

      expect(RuntimeConfig.current.auth!.roleClaimsSource, [
        ClaimSource.idToken,
      ]);
    });

    test('skips a name nobody recognises', () async {
      await loadSources(['idToken', 'refreshToken']);

      expect(RuntimeConfig.current.auth!.roleClaimsSource, [
        ClaimSource.idToken,
      ]);
    });

    test('falls back when no name is recognised', () async {
      // Otherwise a typo reads as "search nowhere", and every role goes missing
      // with nothing to point at.
      await loadSources(['refreshToken']);

      expect(
        RuntimeConfig.current.auth!.roleClaimsSource,
        AuthConfig.defaultRoleClaimsSource,
      );
    });

    test('falls back when the field is not a list', () async {
      await loadSources('idToken');

      expect(
        RuntimeConfig.current.auth!.roleClaimsSource,
        AuthConfig.defaultRoleClaimsSource,
      );
    });
  });

  group('RuntimeConfig.load - the role alias table', () {
    Future<void> loadAliases(Object? aliases) => RuntimeConfig.load(
      client: _dioServing(
        jsonEncode({
          'auth': {
            'issuer': 'https://idp.example/realms/stelaris',
            'clientId': 'stelaris-ui',
            'scopes': ['openid'],
            'roleAliases': ?aliases,
          },
        }),
      ),
    );

    test('is empty when none is configured', () async {
      await loadAliases(null);

      expect(RuntimeConfig.current.auth!.roleAliases, isEmpty);
    });

    test('reads a table of raw value to name', () async {
      await loadAliases({
        '6dbd7a4d-d61c-47f5-8f7d-db368e3f9dae': 'stelaris.admin',
        'fa9833d5-4ec9-4b70-afc4-c85bde6a4601': 'stelaris.editor',
      });

      expect(RuntimeConfig.current.auth!.roleAliases, {
        '6dbd7a4d-d61c-47f5-8f7d-db368e3f9dae': 'stelaris.admin',
        'fa9833d5-4ec9-4b70-afc4-c85bde6a4601': 'stelaris.editor',
      });
    });

    test('trims whitespace on both sides of an entry', () async {
      await loadAliases({'  an-id  ': '  a-name  '});

      expect(RuntimeConfig.current.auth!.roleAliases, {'an-id': 'a-name'});
    });

    test('skips an entry that is not a pair of names', () async {
      await loadAliases({'an-id': 42, 'another-id': '', 'good': 'kept'});

      expect(RuntimeConfig.current.auth!.roleAliases, {'good': 'kept'});
    });

    test('ignores a table that is not an object', () async {
      await loadAliases(['not', 'a', 'table']);

      expect(RuntimeConfig.current.auth!.roleAliases, isEmpty);
    });

    test('a broken table does not discard the rest of the block', () async {
      await loadAliases('nonsense');

      expect(RuntimeConfig.current.auth, isNotNull);
      expect(RuntimeConfig.current.auth!.clientId, 'stelaris-ui');
    });
  });

  group('RuntimeConfig.load - role claim paths', () {
    Future<void> loadRoleClaims(Object? roleClaims) => RuntimeConfig.load(
      client: _dioServing(
        jsonEncode({
          'auth': {
            'issuer': 'https://idp.example/realms/stelaris',
            'clientId': 'stelaris-ui',
            'scopes': ['openid'],
            'roleClaims': ?roleClaims,
          },
        }),
      ),
    );

    test('falls back to the built-in paths when none are named', () async {
      await loadRoleClaims(null);

      expect(
        RuntimeConfig.current.auth!.roleClaims,
        AuthConfig.defaultRoleClaimsFor('stelaris-ui'),
      );
    });

    test('builds the client-scoped default around the configured client',
        () async {
      await loadRoleClaims(null);

      expect(
        RuntimeConfig.current.auth!.roleClaims.map((p) => p.label),
        contains('resource_access.stelaris-ui.roles'),
      );
    });

    test('replaces the defaults rather than extending them', () async {
      await loadRoleClaims(['https://stelaris.example/roles']);

      final List<ClaimPath> claims = RuntimeConfig.current.auth!.roleClaims;
      expect(claims, [const ClaimPath('https://stelaris.example/roles')]);
      expect(claims.map((p) => p.label), isNot(contains('groups')));
    });

    test('keeps several named paths in order', () async {
      await loadRoleClaims(['urn:example:roles', 'team.roles']);

      expect(
        RuntimeConfig.current.auth!.roleClaims.map((p) => p.label),
        ['urn:example:roles', 'team.roles'],
      );
    });

    test('skips an entry that is not a path', () async {
      await loadRoleClaims(['groups', 42, '   ', null]);

      expect(
        RuntimeConfig.current.auth!.roleClaims.map((p) => p.label),
        ['groups'],
      );
    });

    test('falls back to the defaults when nothing in the list is usable',
        () async {
      // A typo that empties the list would otherwise read as "this deployment
      // grants nobody any role", which looks like a permissions problem.
      await loadRoleClaims([42, '  ']);

      expect(
        RuntimeConfig.current.auth!.roleClaims,
        AuthConfig.defaultRoleClaimsFor('stelaris-ui'),
      );
    });

    test('falls back to the defaults when the field is not a list', () async {
      await loadRoleClaims('groups');

      expect(
        RuntimeConfig.current.auth!.roleClaims,
        AuthConfig.defaultRoleClaimsFor('stelaris-ui'),
      );
    });
  });
}
