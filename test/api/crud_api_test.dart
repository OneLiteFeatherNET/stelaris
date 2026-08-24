import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../support/recording_http_client_adapter.dart';
import '../test_model.dart';

void main() {
  late ApiClient apiClient;
  late BaseApi<TestModel> baseApi;

  setUp(() {
    apiClient = ApiClient('http://backend.test/api');
    baseApi = BaseApi<TestModel>(
      apiClient: apiClient,
      endpoint: 'items',
      fromJson: TestModel.fromJson,
      toJson: (model) => model.toJson(),
    );
  });

  group('get', () {
    test('sends a GET to the endpoint and parses the model', () async {
      final model = TestModel(internalId: 1, name: 'Item 1');
      final adapter = RecordingHttpClientAdapter(model.toJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await baseApi.get();

      expect(adapter.lastRequest!.method, 'GET');
      expect(
        adapter.lastRequest!.uri.toString(),
        'http://backend.test/api/items',
      );
      expect(result, model);
    });
  });

  group('add', () {
    test('sends a POST with the model body to the endpoint', () async {
      final model = TestModel(internalId: 2, name: 'New');
      final adapter = RecordingHttpClientAdapter(model.toJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await baseApi.add(model);

      expect(adapter.lastRequest!.method, 'POST');
      expect(
        adapter.lastRequest!.uri.toString(),
        'http://backend.test/api/items',
      );
      expect(adapter.lastRequest!.data, model.toJson());
      expect(result, model);
    });
  });

  group('update', () {
    test('sends a POST to the /update sub-path', () async {
      final model = TestModel(internalId: 3, name: 'Updated');
      final adapter = RecordingHttpClientAdapter(model.toJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await baseApi.update(model);

      expect(adapter.lastRequest!.method, 'POST');
      expect(
        adapter.lastRequest!.uri.toString(),
        'http://backend.test/api/items/update',
      );
      expect(adapter.lastRequest!.data, model.toJson());
      expect(result, model);
    });
  });

  group('remove', () {
    test('sends a DELETE to the /delete/{id} sub-path', () async {
      final model = TestModel(internalId: 4, name: 'Gone');
      final adapter = RecordingHttpClientAdapter(model.toJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await baseApi.remove(model);

      expect(adapter.lastRequest!.method, 'DELETE');
      expect(
        adapter.lastRequest!.uri.toString(),
        'http://backend.test/api/items/delete/4',
      );
      expect(result, model);
    });
  });

  group('getPage', () {
    test('converts the 1-based page to the 0-based query param', () async {
      final page = PaginatedResult<TestModel>(
        items: [TestModel(internalId: 1, name: 'Item 1')],
        totalItems: 1,
        totalPages: 1,
        currentPage: 1,
        pageSize: 10,
      );
      final adapter = RecordingHttpClientAdapter({
        'items': [
          {'id': 1, 'name': 'Item 1'},
        ],
        'totalItems': 1,
        'totalPages': 1,
        'currentPage': 1,
        'pageSize': 10,
      });
      apiClient.dio.httpClientAdapter = adapter;

      final result = await baseApi.getPage(page: 1, size: 10);

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.uri.path, '/api/items');
      expect(adapter.lastRequest!.uri.queryParameters, {
        'page': '0',
        'size': '10',
      });
      expect(result.items, page.items);
      expect(result.totalItems, 1);
    });
  });
}