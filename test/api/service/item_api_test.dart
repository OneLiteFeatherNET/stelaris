import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/service/item_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/recording_http_client_adapter.dart';

void main() {
  late ApiClient apiClient;
  late ItemAPI itemApi;

  setUp(() {
    apiClient = ApiClient('http://backend.test/api');
    itemApi = ItemAPI(apiClient: apiClient);
  });

  group('enchantments', () {
    test('getEnchantments requests the paginated sub-resource', () async {
      const dto = ItemEnchantmentDto(name: 'Sharpness', level: 5, id: 'e1');
      final adapter = RecordingHttpClientAdapter({
        'items': [dto.toJson()],
        'totalItems': 1,
        'totalPages': 1,
        'currentPage': 1,
        'pageSize': 10,
      });
      apiClient.dio.httpClientAdapter = adapter;

      final result = await itemApi.getEnchantments('item-1');

      expect(adapter.lastRequest!.method, 'GET');
      expect(
        adapter.lastRequest!.uri.path,
        '/api/item/item-1/enchantments',
      );
      expect(adapter.lastRequest!.uri.queryParameters, {
        'page': '0',
        'size': '10',
      });
      expect(result.items.single, dto);
    });

    test('addEnchantment PUTs to the enchantment sub-resource', () async {
      const dto = ItemEnchantmentDto(name: 'Fire', level: 1);
      final adapter = RecordingHttpClientAdapter(dto.toJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await itemApi.addEnchantment('item-1', dto);

      expect(adapter.lastRequest!.method, 'PUT');
      expect(
        adapter.lastRequest!.uri.path,
        '/api/item/item-1/enchantment',
      );
      expect(adapter.lastRequest!.data, dto.toJson());
      expect(result, dto);
    });

    test('updateEnchantment POSTs to the enchantment sub-resource', () async {
      const dto = ItemEnchantmentDto(name: 'Fire', level: 2, id: 'e2');
      final adapter = RecordingHttpClientAdapter(dto.toJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await itemApi.updateEnchantment('item-1', dto);

      expect(adapter.lastRequest!.method, 'POST');
      expect(
        adapter.lastRequest!.uri.path,
        '/api/item/item-1/enchantment',
      );
      expect(result, dto);
    });

    test('deleteEnchantment DELETEs by item and enchantment id', () async {
      const dto = ItemEnchantmentDto(name: 'Fire', level: 2, id: 'e2');
      final adapter = RecordingHttpClientAdapter(dto.toJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await itemApi.deleteEnchantment('item-1', dto);

      expect(adapter.lastRequest!.method, 'DELETE');
      expect(
        adapter.lastRequest!.uri.path,
        '/api/item/enchantment/item-1/e2',
      );
      expect(result, dto);
    });
  });

  group('components', () {
    test('getComponents requests the paginated sub-resource', () async {
      const dto = ItemComponentDto(
        id: 'c1',
        componentKey: 'minecraft:food',
        value: {'nutrition': 4, 'saturation': 2.4},
      );
      final adapter = RecordingHttpClientAdapter({
        'items': [dto.toJson()],
        'totalItems': 1,
        'totalPages': 1,
        'currentPage': 1,
        'pageSize': 100,
      });
      apiClient.dio.httpClientAdapter = adapter;

      final result = await itemApi.getComponents('item-1');

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.uri.path, '/api/item/item-1/components');
      expect(adapter.lastRequest!.uri.queryParameters, {
        'page': '0',
        'size': '100',
      });
      expect(result.items.single.componentKey, 'minecraft:food');
      expect(result.items.single.value, {'nutrition': 4, 'saturation': 2.4});
    });

    test('addComponent PUTs to the component sub-resource', () async {
      const dto = ItemComponentDto(
        componentKey: 'minecraft:max_stack_size',
        value: 16,
      );
      final adapter = RecordingHttpClientAdapter(
        dto.copyWith(id: 'c2').toJson(),
      );
      apiClient.dio.httpClientAdapter = adapter;

      final result = await itemApi.addComponent('item-1', dto);

      expect(adapter.lastRequest!.method, 'PUT');
      expect(adapter.lastRequest!.uri.path, '/api/item/item-1/component');
      expect(adapter.lastRequest!.data, dto.toJson());
      expect(result.id, 'c2');
    });

    test('updateComponent POSTs to the component sub-resource', () async {
      const dto = ItemComponentDto(
        id: 'c2',
        componentKey: 'minecraft:max_stack_size',
        value: 8,
      );
      final adapter = RecordingHttpClientAdapter(dto.toJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await itemApi.updateComponent('item-1', dto);

      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.uri.path, '/api/item/item-1/component');
      expect(adapter.lastRequest!.data, dto.toJson());
      expect(result.value, 8);
    });

    test('deleteComponent DELETEs by item and component id', () async {
      const dto = ItemComponentDto(
        id: 'c2',
        componentKey: 'minecraft:glider',
        value: <String, Object?>{},
      );
      final adapter = RecordingHttpClientAdapter(dto.toJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await itemApi.deleteComponent('item-1', dto);

      expect(adapter.lastRequest!.method, 'DELETE');
      expect(adapter.lastRequest!.uri.path, '/api/item/item-1/component/c2');
      expect(result.id, 'c2');
    });
  });

  group('lore', () {
    test('getLore requests the paginated sub-resource', () async {
      const dto = ItemLoreDto(text: 'Once upon a time', id: 'l1');
      final adapter = RecordingHttpClientAdapter({
        'items': [dto.toJson()],
        'totalItems': 1,
        'totalPages': 1,
        'currentPage': 1,
        'pageSize': 10,
      });
      apiClient.dio.httpClientAdapter = adapter;

      final result = await itemApi.getLore('item-1');

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.uri.path, '/api/item/item-1/lore');
      expect(result.items.single, dto);
    });

    test('addLore PUTs to the lore sub-resource', () async {
      const dto = ItemLoreDto(text: 'New lore');
      final adapter = RecordingHttpClientAdapter(dto.toJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await itemApi.addLore('item-1', dto);

      expect(adapter.lastRequest!.method, 'PUT');
      expect(adapter.lastRequest!.uri.path, '/api/item/item-1/lore');
      expect(adapter.lastRequest!.data, dto.toJson());
      expect(result, dto);
    });

    test('updateLore POSTs to the lore sub-resource', () async {
      const dto = ItemLoreDto(text: 'Updated lore', id: 'l2');
      final adapter = RecordingHttpClientAdapter(dto.toJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await itemApi.updateLore('item-1', dto);

      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.uri.path, '/api/item/item-1/lore');
      expect(result, dto);
    });

    test('deleteLore DELETEs by item and lore id', () async {
      const dto = ItemLoreDto(text: 'Gone lore', id: 'l2');
      final adapter = RecordingHttpClientAdapter(dto.toJson());
      apiClient.dio.httpClientAdapter = adapter;

      final result = await itemApi.deleteLore('item-1', dto);

      expect(adapter.lastRequest!.method, 'DELETE');
      expect(adapter.lastRequest!.uri.path, '/api/item/item-1/lore/l2');
      expect(result, dto);
    });

    test('reorderLore PATCHes to the lore reorder sub-resource', () async {
      final adapter = RecordingHttpClientAdapter(null, statusCode: 204);
      apiClient.dio.httpClientAdapter = adapter;

      await itemApi.reorderLore('item-1', entryId: 'l1', newIndex: 2);

      expect(adapter.lastRequest!.method, 'PATCH');
      expect(
        adapter.lastRequest!.uri.path,
        '/api/item/item-1/lore/reorder',
      );
      expect(adapter.lastRequest!.data, {
        'entryId': 'l1',
        'newIndex': 2,
      });
    });
  });
}

