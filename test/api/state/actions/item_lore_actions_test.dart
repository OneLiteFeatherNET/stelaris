import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/item/item_lore_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

/// Sets the selected item, as the form or a click on another item would.
class _SelectItem extends ReduxAction<AppState> {
  _SelectItem(this.item);

  final ItemModel item;

  @override
  AppState reduce() => state.copyWith(selectedItem: item);
}

void main() {
  group('ItemLoreLoadNextPageAction', () {
    const item = ItemModel(
      id: 'item-1',
      uiName: 'item',
      lore: PaginatedResult(
        items: [ItemLoreDto(id: 'l1', text: 'a')],
        totalItems: 4,
        totalPages: 2,
        currentPage: 1,
        pageSize: 2,
      ),
    );
    const nextPage = {
      'items': [
        {'id': 'l2', 'text': 'b'},
      ],
      'totalItems': 4,
      'totalPages': 2,
      'currentPage': 2,
      'pageSize': 2,
    };

    Store<AppState> storeWith(ItemModel item) =>
        Store<AppState>(initialState: AppState(selectedItem: item));

    test('appends the next lore lines to the loaded ones', () async {
      final store = storeWith(item);
      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(nextPage);

      await store.dispatchAndWait(ItemLoreLoadNextPageAction());

      expect(store.state.selectedItem!.lore.items.map((l) => l.id), [
        'l1',
        'l2',
      ]);
      expect(store.state.selectedItem!.lore.currentPage, 2);
      expect(store.state.selectedItem!.isLoadingMoreLoreLines, isFalse);
    });

    test('keeps form edits made while the next lore lines load '
        '(regression)', () async {
      final store = storeWith(item);
      ApiService()
          .itemApi
          .apiClient
          .dio
          .httpClientAdapter = FakeHttpClientAdapter((options) {
        store.dispatchSync(
          _SelectItem(store.state.selectedItem!.copyWith(uiName: 'Renamed')),
        );
        return FakeHttpClientAdapter.response(nextPage);
      });

      await store.dispatchAndWait(ItemLoreLoadNextPageAction());

      expect(store.state.selectedItem!.uiName, 'Renamed');
      expect(store.state.selectedItem!.lore.items.map((l) => l.id), [
        'l1',
        'l2',
      ]);
      expect(store.state.selectedItem!.isLoadingMoreLoreLines, isFalse);
    });

    test('drops the next lore lines when another item is selected while '
        'they load (regression)', () async {
      const other = ItemModel(id: 'item-2', uiName: 'other');
      final store = storeWith(item);
      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            store.dispatchSync(_SelectItem(other));
            return FakeHttpClientAdapter.response(nextPage);
          });

      await store.dispatchAndWait(ItemLoreLoadNextPageAction());

      expect(store.state.selectedItem, other);
    });

    test('drops the next lore lines when the loaded ones changed while '
        'they load', () async {
      final store = storeWith(item);
      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            store.dispatchSync(
              _SelectItem(
                store.state.selectedItem!.copyWith(
                  lore: const PaginatedResult(
                    items: [ItemLoreDto(id: 'fresh', text: 'x')],
                    totalItems: 1,
                    totalPages: 1,
                    currentPage: 1,
                    pageSize: 2,
                  ),
                ),
              ),
            );
            return FakeHttpClientAdapter.response(nextPage);
          });

      await store.dispatchAndWait(ItemLoreLoadNextPageAction());

      expect(store.state.selectedItem!.lore.items.map((l) => l.id), ['fresh']);
    });
  });
}
