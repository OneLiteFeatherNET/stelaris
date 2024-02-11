import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';

class SelectedNotificationAction extends ReduxAction<AppState> {
  final NotificationModel model;

  SelectedNotificationAction(this.model);

  @override
  AppState reduce() {
    return state.copyWith(selectedNotification: model);
  }
}

class RemoveSelectNotificationAction extends ReduxAction<AppState> {
  final NotificationModel model;

  RemoveSelectNotificationAction(this.model);

  @override
  AppState reduce() {
    if (state.selectedItem == null) return state;
    return state.copyWith(selectedNotification: model);
  }
}

class InitNotificationAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    var notifications = await ApiService().notificationAPI.getAll();
    if (notifications.isEmpty) return null;
    return state.copyWith(notifications: notifications);
  }

  InitNotificationAction();
}

class UpdateNotificationAction extends ReduxAction<AppState> {
  final NotificationModel oldEntry;
  final NotificationModel newEntry;

  UpdateNotificationAction(this.oldEntry, this.newEntry);

  @override
  Future<AppState?> reduce() async {
    final notifications = List.of(state.notifications, growable: true);
    int index = notifications.indexWhere((element) => element.id == oldEntry.id);
    notifications.removeAt(index);
    notifications.insert(index, newEntry);
    return state.copyWith(
        notifications: notifications, selectedNotification: newEntry);
  }
}

class NotificationAddAction extends ReduxAction<AppState> {
  final NotificationModel model;

  NotificationAddAction(this.model);

  @override
  Future<AppState?> reduce() async {
    var added = await ApiService().notificationAPI.add(model);
    final models = await ApiService().notificationAPI.getAll();
    return state.copyWith(notifications: models, selectedNotification: added);
  }
}

class RemoveNotificationAction extends ReduxAction<AppState> {
  final NotificationModel model;

  RemoveNotificationAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().notificationAPI.remove(model);
    final models = await ApiService().notificationAPI.getAll();
    return state.copyWith(notifications: models);
  }
}
