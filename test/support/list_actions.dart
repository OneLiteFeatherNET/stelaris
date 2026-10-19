import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/util/copy_model_result.dart';
import 'package:stelaris_models/stelaris_models.dart';

import 'fake_http_client_adapter.dart';

/// Tests what the list actions of every model kind share: loading the list,
/// adding to it, removing from it and copying into it.
///
/// [model] builds a model of the kind, [listOf] and [withList] read and
/// write its list in the state, [isLoadingMore] reads its load-more flag.
void listActionTests<T extends DataModel>({
  required T Function(String id, {String? projectId}) model,
  required PaginatedResult<T> Function(AppState state) listOf,
  required AppState Function(AppState state, PaginatedResult<T> list) withList,
  required bool Function(AppState state) isLoadingMore,
  required ReduxAction<AppState> Function() init,
  required ReduxAction<AppState> Function() refresh,
  required ReduxAction<AppState> Function(T model) add,
  required ReduxAction<AppState> Function(T model) remove,
  required ReduxAction<AppState> Function(T model, CopyModelResult result) copy,
}) {
  /// Answers every request with [json]. All model APIs share one client.
  void respond(Object json) {
    ApiService().itemApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter.json(json);
  }

  Map<String, Object?> json(String id, {String? projectId}) => {
    'id': id,
    'uiName': id,
    'projectId': ?projectId,
  };

  /// A store whose list holds [items] as the loaded part of [totalPages]
  /// pages of [pageSize].
  Store<AppState> storeWith(
    List<T> items, {
    int? totalItems,
    int totalPages = 1,
    int currentPage = 1,
    int pageSize = 10,
    Project? project,
  }) => Store<AppState>(
    initialState: withList(
      AppState(selectedProject: project),
      PaginatedResult<T>(
        items: items,
        totalItems: totalItems ?? items.length,
        totalPages: totalPages,
        currentPage: currentPage,
        pageSize: pageSize,
      ),
    ),
  );

  group('${init().runtimeType}', () {
    test('does nothing when all pages are already loaded, instead of '
        'resetting the list back to page 1 (regression)', () async {
      final loaded = [for (var i = 0; i < 4; i++) model('existing-$i')];
      final store = storeWith(
        loaded,
        totalPages: 2,
        currentPage: 2,
        pageSize: 2,
      );
      final before = store.state;

      await store.dispatchAndWait(init());

      expect(identical(store.state, before), isTrue);
      expect(listOf(store.state).items, loaded);
    });

    /// The page [currentPage] of three pages of two.
    Map<String, Object?> page(int currentPage) => {
      'items': [json('page$currentPage-0'), json('page$currentPage-1')],
      'totalItems': 6,
      'totalPages': 3,
      'currentPage': currentPage,
      'pageSize': 2,
    };

    test('clears the load-more flag after loading the next page, so the '
        'page after it loads too (regression)', () async {
      final store = storeWith(
        [model('page1-0'), model('page1-1')],
        totalItems: 6,
        totalPages: 3,
        pageSize: 2,
      );

      respond(page(2));
      await store.dispatchAndWait(init());
      expect(isLoadingMore(store.state), isFalse);

      respond(page(3));
      await store.dispatchAndWait(init());
      expect(isLoadingMore(store.state), isFalse);
      expect(listOf(store.state).items.map((m) => m.id), [
        'page1-0',
        'page1-1',
        'page2-0',
        'page2-1',
        'page3-0',
        'page3-1',
      ]);
    });
  });

  group('${refresh().runtimeType}', () {
    test('always refetches page 1 and replaces the list, even when more '
        'pages were already loaded', () async {
      final store = storeWith(
        [for (var i = 0; i < 4; i++) model('stale-$i')],
        totalPages: 2,
        currentPage: 2,
        pageSize: 2,
      );
      respond({
        'items': [json('fresh-0')],
        'totalItems': 1,
        'totalPages': 1,
        'currentPage': 1,
        'pageSize': 2,
      });

      await store.dispatchAndWait(refresh());

      expect(listOf(store.state).items.map((e) => e.id), ['fresh-0']);
      expect(listOf(store.state).currentPage, 1);
    });
  });

  group('${add(model('x')).runtimeType}', () {
    test('increments totalItems by one instead of falling back to the '
        'loaded-page count', () async {
      // Only one page (of several) is loaded locally, but the backend
      // knows the real total across all pages.
      final store = storeWith(
        [model('existing-0'), model('existing-1')],
        totalItems: 20,
        totalPages: 10,
        pageSize: 2,
      );
      respond(json('new-id'));

      await store.dispatchAndWait(add(model('new-id')));

      expect(listOf(store.state).totalItems, 21);
      expect(listOf(store.state).items.last.id, 'new-id');
    });
  });

  group('${remove(model('x')).runtimeType}', () {
    test('decrements totalItems by one', () async {
      final existing = model('rm-id');
      final store = storeWith(
        [existing],
        totalItems: 20,
        totalPages: 10,
        pageSize: 2,
      );
      respond(json('rm-id'));

      await store.dispatchAndWait(remove(existing));

      expect(listOf(store.state).totalItems, 19);
      expect(listOf(store.state).items, isEmpty);
    });
  });

  const project = Project(id: 'p1', displayName: 'P1', key: 'p1');
  const other = Project(id: 'p2', displayName: 'P2', key: 'p2');

  group(
    '${copy(model('x'), const CopyModelResult(targetProject: project, name: 'x', key: 'x')).runtimeType}',
    () {
      test('appends a copy into the open project', () async {
        final source = model('source', projectId: 'p1');
        final store = storeWith([source], project: project);
        respond(json('copy', projectId: 'p1'));

        await store.dispatchAndWait(
          copy(
            source,
            const CopyModelResult(
              targetProject: project,
              name: 'Copy',
              key: 'copy',
            ),
          ),
        );

        expect(listOf(store.state).items.map((m) => m.id), ['source', 'copy']);
        expect(listOf(store.state).totalItems, 2);
      });

      test('leaves the state alone for a copy into another project', () async {
        final source = model('source', projectId: 'p1');
        final store = storeWith([source], project: project);
        final before = store.state;
        respond(json('copy', projectId: 'p2'));

        await store.dispatchAndWait(
          copy(
            source,
            const CopyModelResult(
              targetProject: other,
              name: 'Copy',
              key: 'copy',
            ),
          ),
        );

        expect(store.state, before);
      });
    },
  );
}
