import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/item/item_lore_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../../support/recording_http_client_adapter.dart';

void main() {
  group('ItemLoreReorderAction', () {
    test('reorders lore lines locally and calls reorderLore API', () async {
      const line1 = ItemLoreDto(id: 'l1', text: 'First line', orderIndex: 0);
      const line2 = ItemLoreDto(id: 'l2', text: 'Second line', orderIndex: 1);
      const line3 = ItemLoreDto(id: 'l3', text: 'Third line', orderIndex: 2);

      const item = ItemModel(
        id: 'item-1',
        uiName: 'Test Item',
        lore: PaginatedResult<ItemLoreDto>(
          items: [line1, line2, line3],
          totalItems: 3,
          totalPages: 1,
          currentPage: 1,
          pageSize: 10,
        ),
      );

      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedItem: item,
          items: const PaginatedResult<ItemModel>(
            items: [item],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      final adapter = RecordingHttpClientAdapter(null, statusCode: 204);
      ApiService().itemApi.apiClient.dio.httpClientAdapter = adapter;

      await store.dispatchAndWait(
        ItemLoreReorderAction(oldIndex: 0, newIndex: 2),
      );

      expect(adapter.lastRequest!.method, 'PATCH');
      expect(
        adapter.lastRequest!.uri.path,
        '/item/item-1/lore/reorder',
      );
      expect(adapter.lastRequest!.data, {
        'entryId': 'l1',
        'newIndex': 2,
      });

      final loreItems = store.state.selectedItem!.lore.items;
      expect(loreItems.length, 3);
      expect(loreItems[0].id, 'l2');
      expect(loreItems[0].orderIndex, 0);
      expect(loreItems[1].id, 'l3');
      expect(loreItems[1].orderIndex, 1);
      expect(loreItems[2].id, 'l1');
      expect(loreItems[2].orderIndex, 2);

      // Verify state.items is also synced
      expect(store.state.items.items.single.lore.items[2].id, 'l1');
    });

    test('is a no-op when oldIndex == newIndex or out of bounds', () async {
      const line1 = ItemLoreDto(id: 'l1', text: 'First line', orderIndex: 0);
      const item = ItemModel(
        id: 'item-1',
        uiName: 'Test Item',
        lore: PaginatedResult<ItemLoreDto>(
          items: [line1],
          totalItems: 1,
          totalPages: 1,
          currentPage: 1,
          pageSize: 10,
        ),
      );

      final store = Store<AppState>(
        initialState: const AppState().copyWith(selectedItem: item),
      );

      final adapter = RecordingHttpClientAdapter(null, statusCode: 204);
      ApiService().itemApi.apiClient.dio.httpClientAdapter = adapter;

      await store.dispatchAndWait(
        ItemLoreReorderAction(oldIndex: 0, newIndex: 0),
      );
      expect(adapter.lastRequest, isNull);

      await store.dispatchAndWait(
        ItemLoreReorderAction(oldIndex: 0, newIndex: 5),
      );
      expect(adapter.lastRequest, isNull);
    });
  });
}
