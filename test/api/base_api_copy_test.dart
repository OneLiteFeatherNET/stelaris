import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../support/fake_http_client_adapter.dart';

void main() {
  group('BaseApi.copy', () {
    late RequestOptions sent;

    void respondWith() {
      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            sent = options;
            return ResponseBody.fromString(
              '{"id":"item-2","uiName":"Sword (Copy)","projectId":"p2"}',
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          });
    }

    test('posts to the source project with the target fields', () async {
      respondWith();
      const source = ItemModel(id: 'item-1', uiName: 'Sword', projectId: 'p1');

      final copied = await ApiService().itemApi.copy(
        source,
        targetProjectId: 'p2',
        targetName: 'Sword (Copy)',
        targetKey: 'sword-copy',
        relations: {'LORE', 'FLAGS'},
      );

      expect(sent.method, 'POST');
      expect(sent.uri.path, endsWith('/project/p1/item/item-1/copy'));
      expect(sent.data, {
        'targetProjectId': 'p2',
        'targetName': 'Sword (Copy)',
        'targetKey': 'sword-copy',
        'relations': unorderedEquals(['LORE', 'FLAGS']),
      });
      expect(copied.id, 'item-2');
      expect(copied.projectId, 'p2');
    });

    test('leaves out relations when none are chosen', () async {
      respondWith();
      const source = ItemModel(id: 'item-1', uiName: 'Sword', projectId: 'p1');

      await ApiService().itemApi.copy(
        source,
        targetProjectId: 'p1',
        targetName: 'Sword (Copy)',
        targetKey: 'sword-copy',
      );

      expect((sent.data as Map).containsKey('relations'), isFalse);
    });

    test('is available on every BaseApi, e.g. attributes', () async {
      final api = ApiService().attributeApi as BaseApi<AttributeModel>;
      api.apiClient.dio.httpClientAdapter = FakeHttpClientAdapter((options) {
        sent = options;
        return ResponseBody.fromString(
          '{"id":"a-2","uiName":"Speed","projectId":"p1"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await api.copy(
        const AttributeModel(id: 'a-1', uiName: 'Speed', projectId: 'p1'),
        targetProjectId: 'p1',
        targetName: 'Speed (Copy)',
        targetKey: 'speed-copy',
      );

      expect(sent.uri.path, endsWith('/project/p1/attribute/a-1/copy'));
    });
  });
}
