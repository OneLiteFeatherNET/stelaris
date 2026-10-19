import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/list_actions.dart';

void main() {
  listActionTests<AttributeModel>(
    model: (id, {projectId}) =>
        AttributeModel(uiName: id, id: id, projectId: projectId),
    listOf: (state) => state.attributes,
    withList: (state, list) => state.copyWith(attributes: list),
    isLoadingMore: (state) => state.isLoadingAttributesMore,
    init: InitAttributeAction.new,
    refresh: RefreshAttributeAction.new,
    add: AttributeAddAction.new,
    remove: AttributeRemoveAction.new,
    copy: AttributeCopyAction.new,
  );

  group('AttributeAddAction', () {

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

  group('AttributeDatabaseUpdate', () {
    test('drops a second save dispatched right after the first', () async {
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

      final status1 = await store.dispatchAndWait(AttributeDatabaseUpdate());
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
}
