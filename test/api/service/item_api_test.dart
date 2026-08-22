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
  });
}
