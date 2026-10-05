import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/util/copy_model_result.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

void main() {
  group('InitAttributeAction', () {
    test(
      'does nothing when all pages are already loaded, instead of '
      'resetting the list back to page 1 (regression)',
      () async {
        final loadedItems = List.generate(
          4,
          (i) => AttributeModel(uiName: 'existing-$i', id: '$i'),
        );
        final store = Store<AppState>(
          initialState: const AppState().copyWith(
            attributes: PaginatedResult<AttributeModel>(
              items: loadedItems,
              totalItems: 4,
              totalPages: 2,
              currentPage: 2,
              pageSize: 2,
            ),
          ),
        );
        final before = store.state;

        await store.dispatchAndWait(InitAttributeAction());

        expect(identical(store.state, before), isTrue);
        expect(store.state.attributes.items, loadedItems);
      },
    );
  });

  group('RefreshAttributeAction', () {
    test(
      'always refetches page 1 and replaces the list, even when more '
      'pages were already loaded',
      () async {
        final staleItems = List.generate(
          4,
          (i) => AttributeModel(uiName: 'stale-$i', id: 'stale-$i'),
        );
        final store = Store<AppState>(
          initialState: const AppState().copyWith(
            attributes: PaginatedResult<AttributeModel>(
              items: staleItems,
              totalItems: 4,
              totalPages: 2,
              currentPage: 2,
              pageSize: 2,
            ),
          ),
        );

        const fresh = AttributeModel(uiName: 'fresh-0', id: 'fresh-0');
        (ApiService().attributeApi as BaseApi<AttributeModel>)
            .apiClient
            .dio
            .httpClientAdapter = FakeHttpClientAdapter.json({
          'items': [fresh.toJson()],
          'totalItems': 1,
          'totalPages': 1,
          'currentPage': 1,
          'pageSize': 2,
        });

        await store.dispatchAndWait(RefreshAttributeAction());

        expect(store.state.attributes.items.map((e) => e.id), ['fresh-0']);
        expect(store.state.attributes.currentPage, 1);
      },
    );
  });

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

    test('automatically assigns selectedProject.id to added attribute if projectId is null', () async {
      const selectedProject = Project(
        id: 'proj-xyz',
        displayName: 'Test Proj',
        key: 'PROJ_XYZ',
      );

      final store = Store<AppState>(
        initialState: const AppState(selectedProject: selectedProject),
      );

      Map<String, dynamic>? sentBody;
      (ApiService().attributeApi as BaseApi<AttributeModel>).apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
        sentBody = options.data as Map<String, dynamic>?;
        return ResponseBody.fromString(
          jsonEncode({
            'id': 'created-1',
            'uiName': 'Test Attribute',
            'projectId': 'proj-xyz',
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      const newAttr = AttributeModel(uiName: 'Test Attribute');
      await store.dispatchAndWait(AttributeAddAction(newAttr));

      expect(sentBody?['projectId'], 'proj-xyz');
      expect(store.state.attributes.items.last.projectId, 'proj-xyz');
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

  group('AttributeDatabaseUpdate', () {
    test('uses Throttle mixin and throttles rapid dispatches', () async {
      const selected = AttributeModel(uiName: 'attr', id: 'a1');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedAttribute: selected,
          attributes: const PaginatedResult<AttributeModel>(
            items: [selected],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      (ApiService().attributeApi as BaseApi<AttributeModel>)
          .apiClient
          .dio
          .httpClientAdapter =
          FakeHttpClientAdapter.json(selected.toJson());

      final action1 = AttributeDatabaseUpdate();
      expect(action1, isA<Throttle>());
      expect((action1 as Throttle).throttle, 1000);

      final status1 = await store.dispatchAndWait(action1);
      expect(status1.isCompletedOk, isTrue);

      // Immediate second dispatch should be aborted by Throttle
      final action2 = AttributeDatabaseUpdate();
      final status2 = await store.dispatchAndWait(action2);
      expect(status2.isDispatchAborted, isTrue);
    });
  });

  group('AttributeNotesUpdateAction', () {
    test('replaces the list entry and only patches the notes into a '
        'selection of the same attribute', () async {
      const listed = AttributeModel(id: 'attribute-1', uiName: 'Speed');
      // The selection carries an unsaved rename that must survive.
      final selected = listed.copyWith(uiName: 'Renamed', comment: 'Old');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedAttribute: selected,
          attributes: const PaginatedResult<AttributeModel>(
            items: [listed],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      (ApiService().attributeApi as BaseApi<AttributeModel>)
          .apiClient
          .dio
          .httpClientAdapter = FakeHttpClientAdapter.json({
        'id': 'attribute-1',
        'uiName': 'Speed',
        'comment': 'Boss room',
      });

      await store.dispatchAndWait(
        AttributeNotesUpdateAction(listed, 'Boss room'),
      );

      expect(store.state.attributes.items.single.comment, 'Boss room');
      expect(store.state.selectedAttribute!.comment, 'Boss room');
      expect(store.state.selectedAttribute!.uiName, 'Renamed');
    });

    test('leaves a selection of another attribute alone', () async {
      const listed = AttributeModel(id: 'attribute-1', uiName: 'Speed');
      const other = AttributeModel(
        id: 'attribute-2',
        uiName: 'Other',
        comment: 'Old',
      );
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedAttribute: other,
          attributes: const PaginatedResult<AttributeModel>(
            items: [listed, other],
            totalItems: 2,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      (ApiService().attributeApi as BaseApi<AttributeModel>)
          .apiClient
          .dio
          .httpClientAdapter = FakeHttpClientAdapter.json({
        'id': 'attribute-1',
        'uiName': 'Speed',
        'comment': 'Boss room',
      });

      await store.dispatchAndWait(
        AttributeNotesUpdateAction(listed, 'Boss room'),
      );

      expect(store.state.selectedAttribute, other);
    });
  });

  group('AttributeCopyAction', () {
    const project = Project(id: 'p1', displayName: 'P1', key: 'p1');
    const other = Project(id: 'p2', displayName: 'P2', key: 'p2');
    const source = AttributeModel(id: 'a-1', uiName: 'Speed', key: 'speed', projectId: 'p1');

    Store<AppState> store() => Store<AppState>(
      initialState: const AppState().copyWith(
        selectedProject: project,
        attributes: const PaginatedResult<AttributeModel>(
          items: [source],
          totalItems: 1,
          totalPages: 1,
          currentPage: 1,
          pageSize: 10,
        ),
      ),
    );

    void respond(Map<String, dynamic> json) {
      (ApiService().attributeApi as BaseApi<AttributeModel>).apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(json);
    }

    test('appends a copy into the open project', () async {
      final s = store();
      respond({'id': 'a-2', 'uiName': 'Speed (Copy)', 'projectId': 'p1'});

      await s.dispatchAndWait(AttributeCopyAction(
        source,
        const CopyModelResult(targetProject: project, name: 'Speed (Copy)', key: 'speed-copy'),
      ));

      expect(s.state.attributes.items.map((a) => a.id), ['a-1', 'a-2']);
      expect(s.state.attributes.totalItems, 2);
    });

    test('leaves the state alone for a copy into another project', () async {
      final s = store();
      final before = s.state;
      respond({'id': 'a-2', 'uiName': 'Speed', 'projectId': 'p2'});

      await s.dispatchAndWait(AttributeCopyAction(
        source,
        const CopyModelResult(targetProject: other, name: 'Speed', key: 'speed'),
      ));

      expect(s.state, before);
    });
  });
}
