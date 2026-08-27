import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

void main() {
  group('FontAddAction', () {
    test(
      'increments totalItems by one instead of falling back to the '
      'loaded-page count',
      () async {
        // Only one page (of several) is loaded locally, but the backend
        // knows the real total across all pages.
        final loadedPage = List.generate(
          2,
          (i) => FontModel(uiName: 'existing-$i', id: '$i'),
        );
        final store = Store<AppState>(
          initialState: const AppState().copyWith(
            fonts: PaginatedResult<FontModel>(
              items: loadedPage,
              totalItems: 20,
              totalPages: 10,
              currentPage: 1,
              pageSize: 2,
            ),
          ),
        );

        const added = FontModel(uiName: 'new-font', id: 'new-id');
        ApiService().fontApi.apiClient.dio.httpClientAdapter =
            FakeHttpClientAdapter.json(added.toJson());

        await store.dispatchAndWait(FontAddAction(added));

        expect(store.state.fonts.totalItems, 21);
        expect(store.state.fonts.items.last.id, 'new-id');
      },
    );
  });

  group('FontRemoveAction', () {
    test('decrements totalItems by one', () async {
      const existing = FontModel(uiName: 'to-remove', id: 'rm-id');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          fonts: const PaginatedResult<FontModel>(
            items: [existing],
            totalItems: 20,
            totalPages: 10,
            currentPage: 1,
            pageSize: 2,
          ),
        ),
      );

      ApiService().fontApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(existing.toJson());

      await store.dispatchAndWait(FontRemoveAction(existing));

      expect(store.state.fonts.totalItems, 19);
      expect(store.state.fonts.items, isEmpty);
    });

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
      ApiService().fontApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(returned.toJson());

      await store.dispatchAndWait(FontRemoveAction(existing));

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
}
