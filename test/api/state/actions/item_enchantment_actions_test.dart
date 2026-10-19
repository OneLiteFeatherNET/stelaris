import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/item/item_enchantment_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

void main() {
  group('ItemEnchantmentLoadMoreAction', () {
    const item = ItemModel(
      id: 'item-1',
      uiName: 'item',
      enchantments: PaginatedResult(
        items: [ItemEnchantmentDto(id: 'e1', name: 'sharpness', level: 1)],
        totalItems: 4,
        totalPages: 2,
        currentPage: 1,
        pageSize: 2,
      ),
    );
    const nextPage = {
      'items': [
        {'id': 'e2', 'name': 'unbreaking', 'level': 2},
      ],
      'totalItems': 4,
      'totalPages': 2,
      'currentPage': 2,
      'pageSize': 2,
    };

    Store<AppState> storeWith(ItemModel item) =>
        Store<AppState>(initialState: AppState(selectedItem: item));

    test('appends the next enchantments to the loaded ones', () async {
      final store = storeWith(item);
      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(nextPage);

      await store.dispatchAndWait(ItemEnchantmentLoadMoreAction());

      expect(store.state.selectedItem!.enchantments.items.map((e) => e.id), [
        'e1',
        'e2',
      ]);
      expect(store.state.selectedItem!.enchantments.currentPage, 2);
      expect(store.state.selectedItem!.isLoadingMoreEnchantments, isFalse);
    });

    test('loads the next page only once when asked twice in a row '
        '(regression)', () async {
      final store = storeWith(item);
      var requests = 0;
      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            requests++;
            return FakeHttpClientAdapter.response(nextPage);
          });

      await Future.wait([
        store.dispatchAndWait(ItemEnchantmentLoadMoreAction()),
        store.dispatchAndWait(ItemEnchantmentLoadMoreAction()),
      ]);

      expect(requests, 1);
      expect(store.state.selectedItem!.enchantments.items.map((e) => e.id), [
        'e1',
        'e2',
      ]);
    });
  });
}
