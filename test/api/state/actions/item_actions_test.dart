import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

void main() {
  group('ItemAddAction', () {
    test(
      'increments totalItems by one instead of falling back to the '
      'loaded-page count',
      () async {
        // Only one page (of several) is loaded locally, but the backend
        // knows the real total across all pages.
        final loadedPage = List.generate(
          3,
          (i) => ItemModel(uiName: 'existing-$i', id: '$i'),
        );
        final store = Store<AppState>(
          initialState: const AppState().copyWith(
            items: PaginatedResult<ItemModel>(
              items: loadedPage,
              totalItems: 30,
              totalPages: 10,
              currentPage: 1,
              pageSize: 3,
            ),
          ),
        );

        const added = ItemModel(uiName: 'new-item', id: 'new-id');
        ApiService().itemApi.apiClient.dio.httpClientAdapter =
            FakeHttpClientAdapter.json(added.toJson());

        await store.dispatchAndWait(ItemAddAction(added));

        expect(store.state.items.totalItems, 31);
        expect(store.state.items.items.last.id, 'new-id');
        expect(store.state.selectedItem?.id, 'new-id');
      },
    );
  });
}
