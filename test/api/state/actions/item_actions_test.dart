import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/util/copy_model_result.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/list_actions.dart';

void main() {
  listActionTests<ItemModel>(
    model: (id, {projectId}) =>
        ItemModel(uiName: id, id: id, projectId: projectId),
    listOf: (state) => state.items,
    withList: (state, list) => state.copyWith(items: list),
    init: InitItemAction.new,
    refresh: RefreshItemAction.new,
    add: ItemAddAction.new,
    remove: ItemRemoveAction.new,
    copy: ItemCopyAction.new,
  );

  group('ItemAddAction', () {
    test('selects the added item', () async {
      final store = Store<AppState>(initialState: const AppState());
      const added = ItemModel(uiName: 'new-item', id: 'new-id');
      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(added.toJson());

      await store.dispatchAndWait(ItemAddAction(added));

      expect(store.state.selectedItem?.id, 'new-id');
    });

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
      (ApiService().itemApi as BaseApi<ItemModel>)
          .apiClient
          .dio
          .httpClientAdapter = FakeHttpClientAdapter((options) {
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

  // The backend's update response never carries relationships (they have
  // their own endpoints) — saving the form must not wipe them locally.
  group('ItemDatabaseUpdate relationships', () {
    test('keeps the loaded lore, enchantments and flags in the selection, '
        'the list gets the saved state only', () async {
      const lore = PaginatedResult<ItemLoreDto>(
        items: [ItemLoreDto(id: 'l1', text: 'Line', orderIndex: 0)],
        totalItems: 1,
        totalPages: 1,
        currentPage: 1,
        pageSize: 10,
      );
      const enchantments = PaginatedResult<ItemEnchantmentDto>(
        items: [ItemEnchantmentDto(id: 'e1', name: 'sharpness', level: 2)],
        totalItems: 1,
        totalPages: 1,
        currentPage: 1,
        pageSize: 10,
      );
      const saved = ItemModel(
        id: 'item-1',
        uiName: 'Sword',
        lore: lore,
        enchantments: enchantments,
      );
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedItem: saved.copyWith(comment: 'Sharp'),
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
          FakeHttpClientAdapter.json({
            'id': 'item-1',
            'uiName': 'Sword',
            'comment': 'Sharp',
          });

      await store.dispatchAndWait(ItemDatabaseUpdate());

      final selected = store.state.selectedItem!;
      expect(selected.comment, 'Sharp');
      expect(selected.lore, lore);
      expect(selected.enchantments, enchantments);

      // Relationships only live in the selection; the list holds what the
      // server returns, like a fresh list fetch would.
      final listed = store.state.items.items.single;
      expect(listed.comment, 'Sharp');
      expect(listed.lore.items, isEmpty);
      expect(listed.enchantments.items, isEmpty);
    });
  });

  group('ItemNotesUpdateAction', () {
    test('replaces the list entry and only patches the notes into a '
        'selection of the same item', () async {
      const listed = ItemModel(id: 'item-1', uiName: 'Sword');
      // The selection carries an unsaved rename that must survive.
      final selected = listed.copyWith(uiName: 'Renamed', comment: 'Old');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedItem: selected,
          items: const PaginatedResult<ItemModel>(
            items: [listed],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json({
            'id': 'item-1',
            'uiName': 'Sword',
            'comment': 'Boss drop',
          });

      await store.dispatchAndWait(ItemNotesUpdateAction(listed, 'Boss drop'));

      expect(store.state.items.items.single.comment, 'Boss drop');
      expect(store.state.selectedItem!.comment, 'Boss drop');
      expect(store.state.selectedItem!.uiName, 'Renamed');
    });

    test('leaves a selection of another item alone', () async {
      const listed = ItemModel(id: 'item-1', uiName: 'Sword');
      const other = ItemModel(id: 'item-2', uiName: 'Shield', comment: 'Old');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedItem: other,
          items: const PaginatedResult<ItemModel>(
            items: [listed, other],
            totalItems: 2,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json({
            'id': 'item-1',
            'uiName': 'Sword',
            'comment': 'Boss drop',
          });

      await store.dispatchAndWait(ItemNotesUpdateAction(listed, 'Boss drop'));

      expect(store.state.selectedItem, other);
    });
  });

  group('ItemCopyAction', () {
    const project = Project(id: 'p1', displayName: 'P1', key: 'p1');
    const source = ItemModel(
      id: 'item-1',
      uiName: 'Sword',
      key: 'sword',
      projectId: 'p1',
    );

    Store<AppState> storeWith(ItemModel listed) => Store<AppState>(
      initialState: const AppState().copyWith(
        selectedProject: project,
        selectedItem: listed,
        items: PaginatedResult<ItemModel>(
          items: [listed],
          totalItems: 1,
          totalPages: 1,
          currentPage: 1,
          pageSize: 10,
        ),
      ),
    );

    test(
      'appends a copy into the open project and keeps the selection',
      () async {
        final store = storeWith(source);
        ApiService().itemApi.apiClient.dio.httpClientAdapter =
            FakeHttpClientAdapter.json({
              'id': 'item-2',
              'uiName': 'Sword (Copy)',
              'key': 'sword-copy',
              'projectId': 'p1',
            });

        await store.dispatchAndWait(
          ItemCopyAction(
            source,
            const CopyModelResult(
              targetProject: project,
              name: 'Sword (Copy)',
              key: 'sword-copy',
            ),
          ),
        );

        expect(store.state.items.items.map((i) => i.id), ['item-1', 'item-2']);
        expect(store.state.items.totalItems, 2);
        expect(store.state.selectedItem, source);
      },
    );

    test(
      'addresses a model without projectId through the open project',
      () async {
        const unscoped = ItemModel(id: 'item-1', uiName: 'Sword', key: 'sword');
        final store = storeWith(unscoped);
        late Uri requested;
        ApiService().itemApi.apiClient.dio.httpClientAdapter =
            FakeHttpClientAdapter((options) {
              requested = options.uri;
              return ResponseBody.fromString(
                '{"id":"item-2","uiName":"Sword (Copy)","projectId":"p1"}',
                200,
                headers: {
                  Headers.contentTypeHeader: [Headers.jsonContentType],
                },
              );
            });

        await store.dispatchAndWait(
          ItemCopyAction(
            unscoped,
            const CopyModelResult(
              targetProject: project,
              name: 'Sword (Copy)',
              key: 'sword-copy',
            ),
          ),
        );

        expect(requested.path, endsWith('/project/p1/item/item-1/copy'));
      },
    );

    test(
      'addresses a model with an empty projectId through the open project',
      () async {
        const unscoped = ItemModel(
          id: 'item-1',
          uiName: 'Sword',
          key: 'sword',
          projectId: '',
        );
        final store = storeWith(unscoped);
        late Uri requested;
        ApiService().itemApi.apiClient.dio.httpClientAdapter =
            FakeHttpClientAdapter((options) {
              requested = options.uri;
              return ResponseBody.fromString(
                '{"id":"item-2","uiName":"Sword (Copy)","projectId":"p1"}',
                200,
                headers: {
                  Headers.contentTypeHeader: [Headers.jsonContentType],
                },
              );
            });

        await store.dispatchAndWait(
          ItemCopyAction(
            unscoped,
            const CopyModelResult(
              targetProject: project,
              name: 'Sword (Copy)',
              key: 'sword-copy',
            ),
          ),
        );

        expect(requested.path, endsWith('/project/p1/item/item-1/copy'));
      },
    );

    test(
      'appends a copy whose response lacks a projectId under the target',
      () async {
        final store = storeWith(source);
        ApiService().itemApi.apiClient.dio.httpClientAdapter =
            FakeHttpClientAdapter.json({
              'id': 'item-2',
              'uiName': 'Sword (Copy)',
              'key': 'sword-copy',
            });

        await store.dispatchAndWait(
          ItemCopyAction(
            source,
            const CopyModelResult(
              targetProject: project,
              name: 'Sword (Copy)',
              key: 'sword-copy',
            ),
          ),
        );

        expect(store.state.items.items.map((i) => i.id), ['item-1', 'item-2']);
        expect(store.state.items.items.last.projectId, 'p1');
        expect(store.state.items.totalItems, 2);
      },
    );

    test('fails when the backend rejects the copy', () async {
      final store = storeWith(source);
      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json({
            'title': 'Conflict',
            'status': 409,
            'detail': 'An item with this key already exists.',
          }, statusCode: 409);

      // The store has no wrapError, so a backend error reaches the caller.
      await expectLater(
        store.dispatchAndWait(
          ItemCopyAction(
            source,
            const CopyModelResult(
              targetProject: project,
              name: 'Sword',
              key: 'sword',
            ),
          ),
        ),
        throwsA(isA<DioException>()),
      );
      expect(store.state.items.items, [source]);
    });
  });
}
