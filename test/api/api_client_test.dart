import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';

import '../support/fake_http_client_adapter.dart';

void main() {
  test('configures dio with the given base URL', () {
    final apiClient = ApiClient('http://backend.test/api');

    expect(apiClient.baseUrl, 'http://backend.test/api');
    expect(apiClient.dio.options.baseUrl, 'http://backend.test/api');
  });

  test('lets a request through the interceptor chain', () async {
    final apiClient = ApiClient('http://backend.test/api');
    apiClient.dio.httpClientAdapter = FakeHttpClientAdapter.json({
      'ok': true,
    });

    final response = await apiClient.dio.get('/ping');

    expect(response.statusCode, 200);
    expect(response.data, {'ok': true});
  });

  test('rejects the request when the backend errors', () async {
    final apiClient = ApiClient('http://backend.test/api');
    apiClient.dio.httpClientAdapter = FakeHttpClientAdapter.json(
      {'error': 'boom'},
      statusCode: 500,
    );

    await expectLater(
      apiClient.dio.get('/ping'),
      throwsA(isA<DioException>()),
    );
  });
  test('configures dio with default timeouts and allows custom timeouts', () {
    final defaultClient = ApiClient('http://backend.test/api');
    expect(
      defaultClient.dio.options.connectTimeout,
      const Duration(seconds: 10),
    );
    expect(
      defaultClient.dio.options.receiveTimeout,
      const Duration(seconds: 15),
    );
    expect(
      defaultClient.dio.options.sendTimeout,
      const Duration(seconds: 10),
    );

    final customClient = ApiClient(
      'http://backend.test/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 6),
    );
    expect(
      customClient.dio.options.connectTimeout,
      const Duration(seconds: 5),
    );
    expect(
      customClient.dio.options.receiveTimeout,
      const Duration(seconds: 8),
    );
    expect(
      customClient.dio.options.sendTimeout,
      const Duration(seconds: 6),
    );
  });

  test('rejects the request when the backend returns 401 unauthorized', () async {
    final apiClient = ApiClient('http://backend.test/api');
    apiClient.dio.httpClientAdapter = FakeHttpClientAdapter.json(
      {'error': 'unauthorized'},
      statusCode: 401,
    );

    await expectLater(
      apiClient.dio.get('/ping'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
  });

  test('rejects the request when a SocketException occurs', () async {
    final apiClient = ApiClient('http://backend.test/api');
    apiClient.dio.httpClientAdapter = FakeHttpClientAdapter(
      (_) => throw const SocketException('Connection refused'),
    );

    await expectLater(
      apiClient.dio.get('/ping'),
      throwsA(isA<DioException>()),
    );
  });
}
