import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });
}
