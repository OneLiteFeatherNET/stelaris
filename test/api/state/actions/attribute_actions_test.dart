import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

void main() {
  group('AttributeAddAction', () {
    test('increments totalItems by one', () async {
      final loadedPage = List.generate(
        2,
        (i) => AttributeModel(uiName: 'existing-$i', id: '$i'),
      );
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          attributes: PaginatedResult<AttributeModel>(
            items: loadedPage,
            totalItems: 20,
            totalPages: 10,
            currentPage: 1,
            pageSize: 2,
          ),
        ),
      );

      const added = AttributeModel(uiName: 'new-attribute', id: 'new-id');
      (ApiService().attributeApi as BaseApi<AttributeModel>)
          .apiClient
          .dio
          .httpClientAdapter =
          FakeHttpClientAdapter.json(added.toJson());

      await store.dispatchAndWait(AttributeAddAction(added));

      expect(store.state.attributes.totalItems, 21);
      expect(store.state.attributes.items.last.id, 'new-id');
    });
  });

  group('AttributeRemoveAction', () {
    test('decrements totalItems by one', () async {
      const existing = AttributeModel(uiName: 'to-remove', id: 'rm-id');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          attributes: const PaginatedResult<AttributeModel>(
            items: [existing],
            totalItems: 20,
            totalPages: 10,
            currentPage: 1,
            pageSize: 2,
          ),
        ),
      );

      (ApiService().attributeApi as BaseApi<AttributeModel>)
          .apiClient
          .dio
          .httpClientAdapter =
          FakeHttpClientAdapter.json(existing.toJson());

      await store.dispatchAndWait(AttributeRemoveAction(existing));

      expect(store.state.attributes.totalItems, 19);
      expect(store.state.attributes.items, isEmpty);
    });
  });
}
