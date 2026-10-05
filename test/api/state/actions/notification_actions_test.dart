import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/util/copy_model_result.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

void main() {
  group('InitNotificationAction', () {
    test(
      'does nothing when all pages are already loaded, instead of '
      'resetting the list back to page 1 (regression)',
      () async {
        final loadedItems = List.generate(
          4,
          (i) => NotificationModel(uiName: 'existing-$i', id: '$i'),
        );
        final store = Store<AppState>(
          initialState: const AppState().copyWith(
            notifications: PaginatedResult<NotificationModel>(
              items: loadedItems,
              totalItems: 4,
              totalPages: 2,
              currentPage: 2,
              pageSize: 2,
            ),
          ),
        );
        final before = store.state;

        await store.dispatchAndWait(InitNotificationAction());

        expect(identical(store.state, before), isTrue);
        expect(store.state.notifications.items, loadedItems);
      },
    );
  });

  group('RefreshNotificationAction', () {
    test(
      'always refetches page 1 and replaces the list, even when more '
      'pages were already loaded',
      () async {
        final staleItems = List.generate(
          4,
          (i) => NotificationModel(uiName: 'stale-$i', id: 'stale-$i'),
        );
        final store = Store<AppState>(
          initialState: const AppState().copyWith(
            notifications: PaginatedResult<NotificationModel>(
              items: staleItems,
              totalItems: 4,
              totalPages: 2,
              currentPage: 2,
              pageSize: 2,
            ),
          ),
        );

        const fresh = NotificationModel(uiName: 'fresh-0', id: 'fresh-0');
        (ApiService().notificationApi as BaseApi<NotificationModel>)
            .apiClient
            .dio
            .httpClientAdapter = FakeHttpClientAdapter.json({
          'items': [fresh.toJson()],
          'totalItems': 1,
          'totalPages': 1,
          'currentPage': 1,
          'pageSize': 2,
        });

        await store.dispatchAndWait(RefreshNotificationAction());

        expect(store.state.notifications.items.map((e) => e.id), ['fresh-0']);
        expect(store.state.notifications.currentPage, 1);
      },
    );
  });

  group('NotificationAddAction', () {
    test('increments totalItems by one', () async {
      final loadedPage = List.generate(
        2,
        (i) => NotificationModel(uiName: 'existing-$i', id: '$i'),
      );
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          notifications: PaginatedResult<NotificationModel>(
            items: loadedPage,
            totalItems: 20,
            totalPages: 10,
            currentPage: 1,
            pageSize: 2,
          ),
        ),
      );

      const added = NotificationModel(uiName: 'new-notification', id: 'new-id');
      (ApiService().notificationApi as BaseApi<NotificationModel>)
          .apiClient
          .dio
          .httpClientAdapter =
          FakeHttpClientAdapter.json(added.toJson());

      await store.dispatchAndWait(NotificationAddAction(added));

      expect(store.state.notifications.totalItems, 21);
      expect(store.state.notifications.items.last.id, 'new-id');
    });
  });

  group('NotificationRemoveAction', () {
    test('decrements totalItems by one', () async {
      const existing = NotificationModel(uiName: 'to-remove', id: 'rm-id');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          notifications: const PaginatedResult<NotificationModel>(
            items: [existing],
            totalItems: 20,
            totalPages: 10,
            currentPage: 1,
            pageSize: 2,
          ),
        ),
      );

      (ApiService().notificationApi as BaseApi<NotificationModel>)
          .apiClient
          .dio
          .httpClientAdapter =
          FakeHttpClientAdapter.json(existing.toJson());

      await store.dispatchAndWait(NotificationRemoveAction(existing));

      expect(store.state.notifications.totalItems, 19);
      expect(store.state.notifications.items, isEmpty);
    });
  });

  group('NotificationCopyAction', () {
    const project = Project(id: 'p1', displayName: 'P1', key: 'p1');
    const other = Project(id: 'p2', displayName: 'P2', key: 'p2');
    const source = NotificationModel(id: 'n-1', uiName: 'Welcome', key: 'welcome', projectId: 'p1');

    Store<AppState> store() => Store<AppState>(
      initialState: const AppState().copyWith(
        selectedProject: project,
        notifications: const PaginatedResult<NotificationModel>(
          items: [source],
          totalItems: 1,
          totalPages: 1,
          currentPage: 1,
          pageSize: 10,
        ),
      ),
    );

    void respond(Map<String, dynamic> json) {
      (ApiService().notificationApi as BaseApi<NotificationModel>).apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(json);
    }

    test('appends a copy into the open project', () async {
      final s = store();
      respond({'id': 'n-2', 'uiName': 'Welcome (Copy)', 'projectId': 'p1'});

      await s.dispatchAndWait(NotificationCopyAction(
        source,
        const CopyModelResult(targetProject: project, name: 'Welcome (Copy)', key: 'welcome-copy'),
      ));

      expect(s.state.notifications.items.map((n) => n.id), ['n-1', 'n-2']);
      expect(s.state.notifications.totalItems, 2);
    });

    test('leaves the state alone for a copy into another project', () async {
      final s = store();
      final before = s.state;
      respond({'id': 'n-2', 'uiName': 'Welcome', 'projectId': 'p2'});

      await s.dispatchAndWait(NotificationCopyAction(
        source,
        const CopyModelResult(targetProject: other, name: 'Welcome', key: 'welcome'),
      ));

      expect(s.state, before);
    });
  });
}
