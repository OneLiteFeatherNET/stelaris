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

      // Lore only lives in the selection; the list entry stays as fetched.
      expect(store.state.items.items.single, item);
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

    test('executes concurrent reorder actions sequentially using Sequential mixin', () async {
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
        initialState: const AppState().copyWith(selectedItem: item),
      );

      final adapter = RecordingHttpClientAdapter(null, statusCode: 204);
      ApiService().itemApi.apiClient.dio.httpClientAdapter = adapter;

      final action1 = ItemLoreReorderAction(oldIndex: 0, newIndex: 1);
      final action2 = ItemLoreReorderAction(oldIndex: 1, newIndex: 2);

      expect(action1, isA<Sequential>());
      expect(action2, isA<Sequential>());

      final f1 = store.dispatchAndWait(action1);
      final f2 = store.dispatchAndWait(action2);

      final results = await Future.wait([f1, f2]);
      expect(results[0].isCompletedOk, isTrue);
      expect(results[1].isCompletedOk, isTrue);
    });
  });

  group('unsaved form edits', () {
    test('a lore change leaves the list entry untouched',
        () async {
      const line1 = ItemLoreDto(id: 'l1', text: 'First line', orderIndex: 0);
      const line2 = ItemLoreDto(id: 'l2', text: 'Second line', orderIndex: 1);
      const saved = ItemModel(
        id: 'item-1',
        uiName: 'Sword',
        lore: PaginatedResult<ItemLoreDto>(
          items: [line1, line2],
          totalItems: 2,
          totalPages: 1,
          currentPage: 1,
          pageSize: 10,
        ),
      );

      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          // The form renamed the item, but it hasn't been saved yet.
          selectedItem: saved.copyWith(uiName: 'Sword2'),
          items: const PaginatedResult<ItemModel>(
            items: [saved],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          RecordingHttpClientAdapter(null, statusCode: 204);

      await store.dispatchAndWait(
        ItemLoreReorderAction(oldIndex: 0, newIndex: 1),
      );

      // Neither the unsaved rename nor the lore (which only lives in the
      // selection) reaches the list.
      expect(store.state.items.items.single, saved);
      expect(store.state.selectedItem!.uiName, 'Sword2');
      expect(
        store.state.selectedItem!.lore.items.map((l) => l.id),
        ['l2', 'l1'],
      );
    });
  });
}
