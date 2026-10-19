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

  group('lore line changes', () {
    const lines = [
      ItemLoreDto(id: 'l1', text: 'a', orderIndex: 0),
      ItemLoreDto(id: 'l2', text: 'b', orderIndex: 1),
      ItemLoreDto(id: 'l3', text: 'c', orderIndex: 2),
    ];
    const item = ItemModel(
      id: 'item-1',
      uiName: 'item',
      lore: PaginatedResult(
        items: lines,
        totalItems: 3,
        totalPages: 1,
        currentPage: 1,
        pageSize: 10,
      ),
    );
    const other = ItemModel(id: 'item-2', uiName: 'other');

    Store<AppState> storeWith(ItemModel item) =>
        Store<AppState>(initialState: AppState(selectedItem: item));

    /// Answers with [json], after renaming the selection as the form would.
    void respondAfterRename(Store<AppState> store, Object json) {
      ApiService()
          .itemApi
          .apiClient
          .dio
          .httpClientAdapter = FakeHttpClientAdapter((options) {
        store.dispatchSync(
          _SelectItem(store.state.selectedItem!.copyWith(uiName: 'Renamed')),
        );
        return FakeHttpClientAdapter.response(json);
      });
    }

    /// Answers with [json], after selecting [other].
    void respondAfterSelectingOther(Store<AppState> store, Object json) {
      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            store.dispatchSync(_SelectItem(other));
            return FakeHttpClientAdapter.response(json);
          });
    }

    List<String?> loreIds(Store<AppState> store) =>
        store.state.selectedItem!.lore.items.map((l) => l.id).toList();

    group('ItemLoreAddAction', () {
      const added = ItemLoreDto(text: 'd');
      const response = {'id': 'l4', 'text': 'd', 'orderIndex': 3};

      test('keeps form edits made while the line is added '
          '(regression)', () async {
        final store = storeWith(item);
        respondAfterRename(store, response);

        await store.dispatchAndWait(ItemLoreAddAction(added));

        expect(store.state.selectedItem!.uiName, 'Renamed');
        expect(loreIds(store), ['l1', 'l2', 'l3', 'l4']);
        expect(store.state.selectedItem!.lore.totalItems, 4);
      });

      test('leaves another selected item alone (regression)', () async {
        final store = storeWith(item);
        respondAfterSelectingOther(store, response);

        await store.dispatchAndWait(ItemLoreAddAction(added));

        expect(store.state.selectedItem, other);
      });
    });

    group('ItemLoreUpdateAction', () {
      const changed = ItemLoreDto(id: 'l2', text: 'B', orderIndex: 1);
      const response = {'id': 'l2', 'text': 'B', 'orderIndex': 1};

      test('keeps form edits made while the line is saved '
          '(regression)', () async {
        final store = storeWith(item);
        respondAfterRename(store, response);

        await store.dispatchAndWait(ItemLoreUpdateAction(changed));

        expect(store.state.selectedItem!.uiName, 'Renamed');
        expect(store.state.selectedItem!.lore.items.map((l) => l.text), [
          'a',
          'B',
          'c',
        ]);
      });

      test('leaves another selected item alone (regression)', () async {
        final store = storeWith(item);
        respondAfterSelectingOther(store, response);

        await store.dispatchAndWait(ItemLoreUpdateAction(changed));

        expect(store.state.selectedItem, other);
      });
    });

    group('ItemLoreDeleteAction', () {
      const response = {'id': 'l2', 'text': 'b', 'orderIndex': 1};

      test('keeps form edits made while the line is deleted '
          '(regression)', () async {
        final store = storeWith(item);
        respondAfterRename(store, response);

        await store.dispatchAndWait(ItemLoreDeleteAction(lines[1]));

        expect(store.state.selectedItem!.uiName, 'Renamed');
        expect(loreIds(store), ['l1', 'l3']);
        expect(store.state.selectedItem!.lore.totalItems, 2);
      });

      test('leaves another selected item alone (regression)', () async {
        final store = storeWith(item);
        respondAfterSelectingOther(store, response);

        await store.dispatchAndWait(ItemLoreDeleteAction(lines[1]));

        expect(store.state.selectedItem, other);
      });
    });

    group('ItemLoreReorderAction', () {
      ItemLoreReorderAction moveFirstToEnd() =>
          ItemLoreReorderAction(oldIndex: 0, newIndex: 2);

      test('moves the line and renumbers the lines', () async {
        final store = storeWith(item);
        ApiService().itemApi.apiClient.dio.httpClientAdapter =
            FakeHttpClientAdapter.json(const {});

        await store.dispatchAndWait(moveFirstToEnd());

        expect(loreIds(store), ['l2', 'l3', 'l1']);
        expect(store.state.selectedItem!.lore.items.map((l) => l.orderIndex), [
          0,
          1,
          2,
        ]);
      });

      test('keeps form edits made while the line is moved '
          '(regression)', () async {
        final store = storeWith(item);
        respondAfterRename(store, const {});

        await store.dispatchAndWait(moveFirstToEnd());

        expect(store.state.selectedItem!.uiName, 'Renamed');
        expect(loreIds(store), ['l2', 'l3', 'l1']);
      });

      test('keeps lines loaded while the line is moved (regression)', () async {
        final store = storeWith(item);
        ApiService().itemApi.apiClient.dio.httpClientAdapter =
            FakeHttpClientAdapter((options) {
              final current = store.state.selectedItem!;
              store.dispatchSync(
                _SelectItem(
                  current.copyWith(
                    lore: current.lore.copyWith(
                      items: [
                        ...current.lore.items,
                        const ItemLoreDto(id: 'l4', text: 'd', orderIndex: 3),
                      ],
                    ),
                  ),
                ),
              );
              return FakeHttpClientAdapter.response(const {});
            });

        await store.dispatchAndWait(moveFirstToEnd());

        expect(loreIds(store), ['l2', 'l3', 'l1', 'l4']);
        expect(store.state.selectedItem!.lore.items.map((l) => l.orderIndex), [
          0,
          1,
          2,
          3,
        ]);
      });

      test('leaves another selected item alone (regression)', () async {
        final store = storeWith(item);
        respondAfterSelectingOther(store, const {});

        await store.dispatchAndWait(moveFirstToEnd());

        expect(store.state.selectedItem, other);
      });
    });
  });
}
