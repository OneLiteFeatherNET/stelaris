import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/notification_model.dart';
import 'package:stelaris/api/paginated_result.dart';
import 'package:stelaris/api/state/app_state.dart';

class SelectedNotificationAction extends ReduxAction<AppState> {
  final NotificationModel model;

  SelectedNotificationAction(this.model);

  @override
  AppState reduce() => state.copyWith(selectedNotification: model);
}

class RemoveSelectNotificationAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    if (state.selectedNotification == null) return null;
    return state.copyWith(selectedNotification: null);
  }
}

class InitNotificationAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    // If we already have items and more pages, treat this as load-more.
    final hasExisting = state.notifications.items.isNotEmpty;
    final canLoadMore = state.notifications.hasNextPage;

    if (hasExisting && canLoadMore) {
      if (state.isLoadingMoreNotifications) return null;
      dispatchSync(_SetNotificationsLoadMore(true));
      try {
        final current = state.notifications;
        final nextPage = current.currentPage + 1;
        final size = 10;
        final next = await ApiService().notificationApi.getPage(
          page: nextPage,
          size: size,
        );

        final merged = List<NotificationModel>.of(current.items)
          ..addAll(next.items);
        final updated = current.copyWith(
          items: merged,
          totalItems: next.totalItems != 0
              ? next.totalItems
              : current.totalItems,
          totalPages: next.totalPages != 0
              ? next.totalPages
              : current.totalPages,
          currentPage: next.currentPage != 0 ? next.currentPage : nextPage,
          pageSize: next.pageSize != 0 ? next.pageSize : size,
        );
        return state.copyWith(notifications: updated);
      } finally {
        dispatchSync(_SetNotificationsLoadMore(false));
      }
    } else {
      // Initial load (or refresh)
      final PaginatedResult<NotificationModel> result = await ApiService()
          .notificationApi
          .getPage(
            page: 1,
            size: state.notifications.pageSize == 0
                ? 10
                : state.notifications.pageSize,
          );
      return state.copyWith(notifications: result);
    }
  }

  InitNotificationAction();
}

/// Internal action to manage the loading state for notifications pagination.
///
/// This private action controls the `isLoadingMoreNotifications` flag in the state,
/// preventing multiple simultaneous load-more requests. It's used internally
/// by InitNotificationAction during pagination operations.
class _SetNotificationsLoadMore extends ReduxAction<AppState> {
  final bool value;

  _SetNotificationsLoadMore(this.value);

  @override
  AppState reduce() => state.copyWith(isLoadingMoreNotifications: value);
}

class UpdateNotificationAction extends ReduxAction<AppState> {
  final NotificationModel newEntry;

  UpdateNotificationAction(this.newEntry);

  @override
  Future<AppState?> reduce() async =>
      state.copyWith(selectedNotification: newEntry);
}

class NotificationAddAction extends ReduxAction<AppState> {
  final NotificationModel model;

  NotificationAddAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final NotificationModel databaseModel = await ApiService().notificationApi
        .add(model);
    final List<NotificationModel> updatedList = List.of(
      state.notifications.items,
      growable: true,
    )..add(databaseModel);

    return _updateNotificationInState(state, updatedList, databaseModel);
  }
}

class NotificationRemoveAction extends ReduxAction<AppState> {
  final NotificationModel model;

  NotificationRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().notificationApi.remove(model);
    final List<NotificationModel> updatedList = List.of(
      state.notifications.items,
      growable: true,
    )..remove(model);

    final NotificationModel? selectedModel =
        state.selectedNotification?.id == model.id
        ? null
        : state.selectedNotification;

    return _updateNotificationInState(state, updatedList, selectedModel);
  }
}

class NotificationDatabaseUpdate extends ReduxAction<AppState> {
  NotificationDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedNotification == null) return null;

    final NotificationModel selected = state.selectedNotification!;
    final NotificationModel dbModel = await ApiService().notificationApi.update(
      selected,
    );

    final List<NotificationModel> updatedList = List.of(
      state.notifications.items,
      growable: true,
    );
    final int index = updatedList.indexWhere(
      (element) => element.id == selected.id,
    );

    if (index != -1) {
      updatedList[index] = dbModel;
    }

    return _updateNotificationInState(state, updatedList, dbModel);
  }
}

AppState _updateNotificationInState(
  AppState state,
  List<NotificationModel> newItems,
  NotificationModel? selectedItem, {
  int? totalItems,
}) {
  final updated = state.notifications.copyWith(
    items: newItems,
    totalItems: totalItems ?? state.items.totalItems,
    totalPages: state.items.totalPages,
    currentPage: state.items.currentPage,
    pageSize: state.items.pageSize,
  );
  return state.copyWith(
    notifications: updated,
    selectedNotification: selectedItem,
  );
}
