import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/list_actions.dart';
import '../../../support/recording_http_client_adapter.dart';

void main() {
  listActionTests<FontModel>(
    model: (id, {projectId}) =>
        FontModel(uiName: id, id: id, projectId: projectId),
    listOf: (state) => state.fonts,
    withList: (state, list) => state.copyWith(fonts: list),
    isLoadingMore: (state) => state.isLoadingMoreFonts,
    selectedOf: (state) => state.selectedFont,
    withSelected: (state, model) => state.copyWith(selectedFont: model),
    init: InitFontAction.new,
    refresh: RefreshFontAction.new,
    add: FontAddAction.new,
    remove: FontRemoveAction.new,
    copy: FontCopyAction.new,
  );

  group('FontRemoveAction', () {

    test('falls back to selectedProject id when model has no projectId', () async {
      const existing = FontModel(uiName: 'to-remove', id: 'rm-id');
      const project = Project(displayName: 'P', id: 'proj-99', key: 'p');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedProject: project,
          fonts: const PaginatedResult<FontModel>(
            items: [existing],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      const returned = FontModel(
        uiName: 'to-remove',
        id: 'rm-id',
        projectId: 'proj-99',
      );
      final adapter = RecordingHttpClientAdapter(returned.toJson());
      ApiService().fontApi.apiClient.dio.httpClientAdapter = adapter;

      await store.dispatchAndWait(FontRemoveAction(existing));

      expect(
        adapter.lastRequest!.uri.path,
        endsWith('/project/proj-99/font/delete/rm-id'),
      );
      expect(store.state.fonts.totalItems, 0);
      expect(store.state.fonts.items, isEmpty);
    });
  });

  group('FontDatabaseUpdate', () {
    test('updates font in state list and preserves selected font', () async {
      const existing = FontModel(
        uiName: 'old-name',
        id: 'f1',
        projectId: 'proj-1',
      );
      const project = Project(displayName: 'P', id: 'proj-1', key: 'p');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedProject: project,
          selectedFont: existing.copyWith(uiName: 'new-name'),
          fonts: const PaginatedResult<FontModel>(
            items: [existing],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      const dbUpdated = FontModel(
        uiName: 'new-name',
        id: 'f1',
        projectId: 'proj-1',
      );
      ApiService().fontApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(dbUpdated.toJson());

      await store.dispatchAndWait(FontDatabaseUpdate());

      expect(store.state.fonts.items.single.uiName, 'new-name');
      expect(store.state.fonts.items.single.projectId, 'proj-1');
      expect(store.state.selectedFont?.uiName, 'new-name');
    });
  });

  // The backend's update response never carries the chars (they have their
  // own endpoints) — saving the form must not wipe them locally.
  group('FontDatabaseUpdate relationships', () {
    test('keeps the loaded chars in the selection, the list gets the saved '
        'state only', () async {
      const chars = PaginatedResult<FontStringDTO>(
        items: [FontStringDTO(id: 'c1', line: 'a')],
        totalItems: 1,
        totalPages: 1,
        currentPage: 1,
        pageSize: 10,
      );
      const saved = FontModel(
        id: 'f1',
        uiName: 'Default',
        projectId: 'proj-1',
        chars: chars,
      );
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedFont: saved.copyWith(uiName: 'Renamed'),
          fonts: const PaginatedResult<FontModel>(
            items: [saved],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      ApiService().fontApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json({
            'id': 'f1',
            'uiName': 'Renamed',
            'projectId': 'proj-1',
          });

      await store.dispatchAndWait(FontDatabaseUpdate());

      expect(store.state.selectedFont!.uiName, 'Renamed');
      expect(store.state.selectedFont!.chars, chars);

      // Relationships only live in the selection; the list holds what the
      // server returns, like a fresh list fetch would.
      final listed = store.state.fonts.items.single;
      expect(listed.uiName, 'Renamed');
      expect(listed.chars.items, isEmpty);
    });
  });
}
