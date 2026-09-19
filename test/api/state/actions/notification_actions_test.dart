import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
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
}
