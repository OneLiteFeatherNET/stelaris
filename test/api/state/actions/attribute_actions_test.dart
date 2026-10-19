import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/list_actions.dart';

void main() {
  listActionTests<AttributeModel>(
    model: (id, {projectId}) =>
        AttributeModel(uiName: id, id: id, projectId: projectId),
    listOf: (state) => state.attributes,
    withList: (state, list) => state.copyWith(attributes: list),
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

  group('OpenSharedAttributeAction', () {
    const projectA = Project(id: 'A', displayName: 'A', key: 'A');
    const projectB = Project(id: 'B', displayName: 'B', key: 'B');
    const attribute = AttributeModel(uiName: 'attr', id: 'a1', projectId: 'B');

    /// Answers project and attribute lookups by path and records every
    /// requested path, so a test can assert what was (not) fetched.
    List<String> serve({bool attributeMissing = false}) {
      final List<String> paths = [];
      (ApiService().attributeApi as BaseApi<AttributeModel>)
          .apiClient
          .dio
          .httpClientAdapter = FakeHttpClientAdapter((options) {
        final String path = options.uri.path;
        paths.add(path);
        final bool isAttribute = path.endsWith('/attribute/a1');
        final Object body = isAttribute ? attribute.toJson() : projectB.toJson();
        return ResponseBody.fromString(
          jsonEncode(isAttribute && attributeMissing ? {} : body),
          isAttribute && attributeMissing ? 404 : 200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      return paths;
    }

    test('loads the attribute into the already selected project', () async {
      final paths = serve();
      final store = Store<AppState>(
        initialState: const AppState(selectedProject: projectB),
      );

      await store.dispatchAndWait(OpenSharedAttributeAction('B', 'a1'));

      expect(paths, [endsWith('/project/B/attribute/a1')]);
      expect(store.state.selectedAttribute?.id, 'a1');
      expect(store.state.selectedProject?.id, 'B');
    });

    test('switches to a known project without fetching it', () async {
      final paths = serve();
      final store = Store<AppState>(
        initialState: const AppState(
          selectedProject: projectA,
          projects: [projectA, projectB],
        ),
      );

      await store.dispatchAndWait(OpenSharedAttributeAction('B', 'a1'));

      expect(paths, [endsWith('/project/B/attribute/a1')]);
      expect(store.state.selectedProject?.id, 'B');
      expect(store.state.selectedAttribute?.id, 'a1');
    });

    test('fetches a project that is not known yet', () async {
      final paths = serve();
      final store = Store<AppState>(initialState: const AppState());

      await store.dispatchAndWait(OpenSharedAttributeAction('B', 'a1'));

      expect(paths.first, endsWith('/project/B'));
      expect(store.state.selectedProject?.id, 'B');
      expect(store.state.selectedAttribute?.id, 'a1');
    });

    test('keeps an open attribute and its unsaved edits', () async {
      final paths = serve();
      const edited = AttributeModel(uiName: 'edited', id: 'a1', projectId: 'B');
      final store = Store<AppState>(
        initialState: const AppState(
          selectedProject: projectB,
          selectedAttribute: edited,
          unsavedChanges: NavigationEntry.attributes,
        ),
      );

      await store.dispatchAndWait(OpenSharedAttributeAction('B', 'a1'));

      expect(paths, isEmpty);
      expect(store.state.selectedAttribute, edited);
      expect(store.state.unsavedChanges, NavigationEntry.attributes);
    });

    test('reports a missing attribute and selects nothing', () async {
      serve(attributeMissing: true);
      final store = Store<AppState>(
        initialState: const AppState(selectedProject: projectB),
      );

      await expectLater(
        store.dispatchAndWait(OpenSharedAttributeAction('B', 'a1')),
        throwsA(isA<DioException>()),
      );
      expect(store.state.selectedAttribute, isNull);
    });
  });

  group('EnsureProjectSelectedAction', () {
    test('does nothing when the project is already selected', () async {
      const project = Project(id: 'B', displayName: 'B', key: 'B');
      final store = Store<AppState>(
        initialState: const AppState(selectedProject: project),
      );

      await store.dispatchAndWait(EnsureProjectSelectedAction('B'));

      expect(store.state.selectedProject, project);
    });
  });
}
