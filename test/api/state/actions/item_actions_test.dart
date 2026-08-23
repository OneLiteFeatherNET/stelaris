import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/base_api.dart';
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

    test('automatically assigns selectedProject.id to added item if projectId is null', () async {
      const selectedProject = Project(
        id: 'proj-xyz',
        displayName: 'Test Proj',
        key: 'PROJ_XYZ',
      );

      final store = Store<AppState>(
        initialState: const AppState(selectedProject: selectedProject),
      );

      Map<String, dynamic>? sentBody;
      (ApiService().itemApi as BaseApi<ItemModel>).apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
        sentBody = options.data as Map<String, dynamic>?;
        return ResponseBody.fromString(
          jsonEncode({
            'id': 'created-1',
            'uiName': 'My Sword',
            'projectId': 'proj-xyz',
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      const newItem = ItemModel(uiName: 'My Sword');
      await store.dispatchAndWait(ItemAddAction(newItem));

      expect(sentBody?['projectId'], 'proj-xyz');
      expect(store.state.items.items.last.projectId, 'proj-xyz');
    });
  });

  group('ItemRemoveAction', () {
    test('decrements totalItems by one', () async {
      const existing = ItemModel(uiName: 'to-remove', id: 'rm-id');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          items: const PaginatedResult<ItemModel>(
            items: [existing],
            totalItems: 20,
            totalPages: 10,
            currentPage: 1,
            pageSize: 2,
          ),
        ),
      );

      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(existing.toJson());

      await store.dispatchAndWait(ItemRemoveAction(existing));

      expect(store.state.items.totalItems, 19);
      expect(store.state.items.items, isEmpty);
    });
  });
}
