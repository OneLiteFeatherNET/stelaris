import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/auth/token_source.dart';

/// A session double that counts renewals, because "exactly one" is the point of
/// several of these tests.
class FakeTokens implements TokenSource {
  FakeTokens({this.token = 'token-1', this.renewsTo = 'token-2'});

  String? token;
  final String? renewsTo;
  int refreshes = 0;
  bool refreshSucceeds = true;

  @override
  String? get accessToken => token;

  @override
  Future<bool> refresh() async {
    refreshes++;
    // A real renewal is a network round trip; yielding here lets any other
    // request that is mid-flight interleave, which is what would expose a
    // second renewal slipping through.
    await Future<void>.delayed(Duration.zero);
    if (!refreshSucceeds) {
      return false;
    }
    token = renewsTo;
    return true;
  }
}

/// Answers each request from [reply], recording what it was asked.
class RecordingAdapter implements HttpClientAdapter {
  RecordingAdapter(this.reply);

  final ResponseBody Function(RequestOptions options) reply;

  /// The authorization header as it was at the moment of the call.
  ///
  /// Snapshotted rather than kept as the [RequestOptions] it came from: a
  /// retry re-sends the same options object with a new header, so holding the
  /// object would show every earlier call carrying the final token.
  final List<String?> authorizations = <String?>[];

  int get calls => authorizations.length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    authorizations.add(
      options.headers[HttpHeaders.authorizationHeader] as String?,
    );
    return reply(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(Object? body, int status) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

/// Refuses whatever bearer [staleToken] carries, accepts anything else.
RecordingAdapter refusing(String staleToken) => RecordingAdapter((options) {
  final String? auth = options.headers[HttpHeaders.authorizationHeader] as String?;
  if (auth == 'Bearer $staleToken') {
    return json({'detail': 'expired'}, 401);
  }
  return json({'ok': true}, 200);
});

ApiClient clientWith(TokenSource? tokens, HttpClientAdapter adapter) {
  final client = ApiClient('http://backend.test/api', tokens: tokens);
  client.dio.httpClientAdapter = adapter;
  return client;
}

void main() {
  group('the bearer credential', () {
    test('travels with every request while a session is active', () async {
      final adapter = RecordingAdapter((_) => json({'ok': true}, 200));
      final client = clientWith(FakeTokens(), adapter);

      await client.dio.get<dynamic>('/items');

      expect(adapter.authorizations.single, 'Bearer token-1');
    });

    test('is the access token, never the id token', () async {
      // The id token identifies the person to this app; sending it to the
      // backend would be handing over the wrong credential entirely.
      final adapter = RecordingAdapter((_) => json({'ok': true}, 200));
      final tokens = FakeTokens(token: 'access-token');
      final client = clientWith(tokens, adapter);

      await client.dio.get<dynamic>('/items');

      expect(adapter.authorizations.single, 'Bearer access-token');
      expect(adapter.authorizations.single, isNot(contains('id-token')));
    });

    test('is absent in a deployment with no identity provider', () async {
      final adapter = RecordingAdapter((_) => json({'ok': true}, 200));
      final client = clientWith(null, adapter);

      await client.dio.get<dynamic>('/items');

      expect(adapter.authorizations.single, isNull);
    });

    test('is absent while a configured session holds no token yet', () async {
      final adapter = RecordingAdapter((_) => json({'ok': true}, 200));
      final client = clientWith(FakeTokens(token: null), adapter);

      await client.dio.get<dynamic>('/items');

      expect(adapter.authorizations.single, isNull);
    });
  });

  group('a request the backend refuses as unauthenticated', () {
    test('is renewed and retried once, and its result is delivered', () async {
      final adapter = refusing('token-1');
      final tokens = FakeTokens();
      final client = clientWith(tokens, adapter);

      final response = await client.dio.get<dynamic>('/items');

      expect(response.statusCode, 200);
      expect(tokens.refreshes, 1);
      // The caller sees one answer; the rejection never surfaced.
      expect(adapter.authorizations, ['Bearer token-1', 'Bearer token-2']);
    });

    test('is not retried twice when the backend refuses again', () async {
      // A backend that answers 401 whatever we send must not put this in a
      // loop.
      final adapter = RecordingAdapter((_) => json({'detail': 'no'}, 401));
      final tokens = FakeTokens();
      final client = clientWith(tokens, adapter);

      await expectLater(
        client.dio.get<dynamic>('/items'),
        throwsA(isA<DioException>()),
      );
      expect(tokens.refreshes, 1);
      expect(adapter.calls, 2);
    });

    test('is rejected when the session cannot be renewed', () async {
      final adapter = refusing('token-1');
      final tokens = FakeTokens()..refreshSucceeds = false;
      final client = clientWith(tokens, adapter);

      await expectLater(
        client.dio.get<dynamic>('/items'),
        throwsA(isA<DioException>()),
      );
      expect(tokens.refreshes, 1);
      // No retry was attempted: there was nothing new to send.
      expect(adapter.calls, 1);
    });

    test('is rejected exactly as before when no provider is configured', () async {
      // The rollout gate again: a deployment whose backend is not yet
      // validating tokens sees the behaviour it has always seen.
      final adapter = RecordingAdapter((_) => json({'detail': 'no'}, 401));
      final client = clientWith(null, adapter);

      await expectLater(
        client.dio.get<dynamic>('/items'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 1);
      expect(adapter.authorizations.single, isNull);
    });
  });

  group('several requests hitting an expired token at once', () {
    test('renew it once between them', () async {
      // Providers rotate refresh tokens, and one presented twice ends the
      // session for everybody - so a burst must produce one renewal, not one
      // per request.
      final adapter = refusing('token-1');
      final tokens = FakeTokens();
      final client = clientWith(tokens, adapter);

      final responses = await Future.wait([
        client.dio.get<dynamic>('/items'),
        client.dio.get<dynamic>('/fonts'),
        client.dio.get<dynamic>('/sounds'),
        client.dio.get<dynamic>('/attributes'),
        client.dio.get<dynamic>('/notifications'),
      ]);

      expect(tokens.refreshes, 1);
      expect(responses.map((r) => r.statusCode), everyElement(200));
    });

    test('all carry the renewed token afterwards', () async {
      final adapter = refusing('token-1');
      final tokens = FakeTokens();
      final client = clientWith(tokens, adapter);

      await Future.wait([
        client.dio.get<dynamic>('/items'),
        client.dio.get<dynamic>('/fonts'),
      ]);

      expect(
        adapter.authorizations.where((a) => a == 'Bearer token-2').length,
        greaterThanOrEqualTo(2),
      );
    });
  });

  group('everything that is not a 401', () {
    test('a refusal of the action renews nothing', () async {
      // 403 means the credential was accepted and the action was not. Renewing
      // would be pointless, and would hide a permissions problem behind a
      // sign-in loop.
      final adapter = RecordingAdapter((_) => json({'detail': 'nope'}, 403));
      final tokens = FakeTokens();
      final client = clientWith(tokens, adapter);

      await expectLater(
        client.dio.get<dynamic>('/items'),
        throwsA(isA<DioException>()),
      );
      expect(tokens.refreshes, 0);
      expect(adapter.calls, 1);
    });

    test('a server error renews nothing and reports as before', () async {
      final adapter = RecordingAdapter(
        (_) => json({'title': 'boom', 'status': 500}, 500),
      );
      final tokens = FakeTokens();
      final client = clientWith(tokens, adapter);

      try {
        await client.dio.get<dynamic>('/items');
        fail('expected the server error to surface');
      } on DioException catch (error) {
        final detail = ProblemDetail.fromDioException(error);
        expect(detail.status, 500);
      }
      expect(tokens.refreshes, 0);
    });

    test('a connection failure renews nothing and reports as before', () async {
      final client = ApiClient('http://backend.test/api', tokens: FakeTokens());
      client.dio.httpClientAdapter = _FailingAdapter();

      try {
        await client.dio.get<dynamic>('/items');
        fail('expected the connection failure to surface');
      } on DioException catch (error) {
        expect(ProblemDetail.fromDioException(error), isNotNull);
      }
    });
  });
}

class _FailingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => throw DioException.connectionError(
    requestOptions: options,
    reason: 'no backend',
  );

  @override
  void close({bool force = false}) {}
}
