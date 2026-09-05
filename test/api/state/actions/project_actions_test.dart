import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

void main() {
  group('SelectProjectAction', () {
    test('updates selectedProject and clears all entity caches and selections', () {
      const projectA = Project(
        id: 'proj-a',
        displayName: 'Project A',
        key: 'PROJ_A',
      );
      const projectB = Project(
        id: 'proj-b',
        displayName: 'Project B',
        key: 'PROJ_B',
      );

      const existingItem = ItemModel(uiName: 'Item 1', id: 'i1', projectId: 'proj-a');
      const existingFont = FontModel(uiName: 'Font 1', id: 'f1', projectId: 'proj-a');
      const existingNotification = NotificationModel(uiName: 'Notif 1', id: 'n1', projectId: 'proj-a');
      const existingAttribute = AttributeModel(uiName: 'Attr 1', id: 'a1', projectId: 'proj-a');
      final existingSound = SoundEventModel(uiName: 'Sound 1', id: 's1', projectId: 'proj-a');

      final store = Store<AppState>(
        initialState: AppState(
          projects: const [projectA, projectB],
          selectedProject: projectA,
          items: const PaginatedResult<ItemModel>(
            items: [existingItem],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
          fonts: const PaginatedResult<FontModel>(
            items: [existingFont],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
          notifications: const PaginatedResult<NotificationModel>(
            items: [existingNotification],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
          attributes: const PaginatedResult<AttributeModel>(
            items: [existingAttribute],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
          soundEvents: PaginatedResult<SoundEventModel>(
            items: [existingSound],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
          selectedItem: existingItem,
          selectedFont: existingFont,
          selectedNotification: existingNotification,
          selectedAttribute: existingAttribute,
          selectedSoundEvent: existingSound,
        ),
      );

      store.dispatchSync(SelectProjectAction(projectB));

      expect(store.state.selectedProject, projectB);
      expect(store.state.items.items, isEmpty);
      expect(store.state.fonts.items, isEmpty);
      expect(store.state.notifications.items, isEmpty);
      expect(store.state.attributes.items, isEmpty);
      expect(store.state.soundEvents.items, isEmpty);
      expect(store.state.selectedItem, isNull);
      expect(store.state.selectedFont, isNull);
      expect(store.state.selectedNotification, isNull);
      expect(store.state.selectedAttribute, isNull);
      expect(store.state.selectedSoundEvent, isNull);
    });
  });

  group('AddProjectAction', () {
    test('adds project to list and selects it by default', () async {
      const newProj = Project(id: 'proj-new', displayName: 'New Proj', key: 'key_new');
      ApiService().projectApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(newProj.toJson());

      final store = Store<AppState>(initialState: const AppState());
      await store.dispatchAndWait(AddProjectAction(newProj));

      expect(store.state.projects.length, 1);
      expect(store.state.projects.first, newProj);
      expect(store.state.selectedProject, newProj);
    });

    test('adds project to list without selecting when select is false', () async {
      const existing = Project(id: 'proj-old', displayName: 'Old Proj', key: 'key_old');
      const newProj = Project(id: 'proj-new', displayName: 'New Proj', key: 'key_new');
      ApiService().projectApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(newProj.toJson());

      final store = Store<AppState>(
        initialState: const AppState(projects: [existing], selectedProject: existing),
      );
      await store.dispatchAndWait(AddProjectAction(newProj, select: false));

      expect(store.state.projects.length, 2);
      expect(store.state.projects.last, newProj);
      expect(store.state.selectedProject, existing);
    });
  });

  group('UpdateProjectAction', () {
    test('updates project in list and updates selectedProject if matched', () async {
      const orig = Project(id: 'proj-1', displayName: 'Original', key: 'k1');
      const updated = Project(id: 'proj-1', displayName: 'Updated', key: 'k1');

      ApiService().projectApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(updated.toJson());

      final store = Store<AppState>(
        initialState: const AppState(projects: [orig], selectedProject: orig),
      );
      await store.dispatchAndWait(UpdateProjectAction(updated));

      expect(store.state.projects.first.displayName, 'Updated');
      expect(store.state.selectedProject?.displayName, 'Updated');
    });

    test('appends updated project if not found in existing list', () async {
      const updated = Project(id: 'proj-1', displayName: 'Updated', key: 'k1');

      ApiService().projectApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(updated.toJson());

      final store = Store<AppState>(initialState: const AppState());
      await store.dispatchAndWait(UpdateProjectAction(updated));

      expect(store.state.projects.length, 1);
      expect(store.state.projects.first.displayName, 'Updated');
    });
  });

  group('SetProjectsAction', () {
    test('replaces local projects list', () {
      const p1 = Project(id: 'p1', displayName: 'P1', key: 'k1');
      const p2 = Project(id: 'p2', displayName: 'P2', key: 'k2');

      final store = Store<AppState>(initialState: const AppState());
      store.dispatchSync(SetProjectsAction([p1, p2]));

      expect(store.state.projects, [p1, p2]);
    });
  });

  group('RemoveProjectAction', () {
    test('removes project from list and unselects if currently selected', () async {
      const p1 = Project(id: 'p1', displayName: 'P1', key: 'k1');
      const p2 = Project(id: 'p2', displayName: 'P2', key: 'k2');

      ApiService().projectApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(p1.toJson());

      final store = Store<AppState>(
        initialState: const AppState(projects: [p1, p2], selectedProject: p1),
      );
      await store.dispatchAndWait(RemoveProjectAction(p1));

      expect(store.state.projects, [p2]);
      expect(store.state.selectedProject, isNull);
    });
  });

  group('DeleteAllProjectsAction', () {
    test('clears all projects and resets selectedProject', () async {
      const p1 = Project(id: 'p1', displayName: 'P1', key: 'k1');

      ApiService().projectApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json([p1.toJson()]);

      final store = Store<AppState>(
        initialState: const AppState(projects: [p1], selectedProject: p1),
      );
      await store.dispatchAndWait(DeleteAllProjectsAction());

      expect(store.state.projects, isEmpty);
      expect(store.state.selectedProject, isNull);
    });
  });

  group('InitProjectAction', () {
    test('fetches projects and retains matching selectedProject', () async {
      const p1 = Project(id: 'p1', displayName: 'P1 Updated', key: 'k1');
      const p2 = Project(id: 'p2', displayName: 'P2', key: 'k2');
      const prevP1 = Project(id: 'p1', displayName: 'P1 Old', key: 'k1');

      final paginated = const PaginatedResult<Project>(
        items: [p1, p2],
        totalItems: 2,
        totalPages: 1,
        currentPage: 1,
        pageSize: 50,
      );

      ApiService().projectApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(paginated.toJson((p) => p.toJson()));

      final store = Store<AppState>(
        initialState: const AppState(projects: [prevP1], selectedProject: prevP1),
      );
      await store.dispatchAndWait(InitProjectAction());

      expect(store.state.projects.length, 2);
      expect(store.state.selectedProject?.displayName, 'P1 Updated');
    });
  });
}

