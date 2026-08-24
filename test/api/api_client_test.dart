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
}
