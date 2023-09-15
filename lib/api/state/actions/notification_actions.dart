import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/api_service.dart';

import '../../model/notification_model.dart';
import '../app_state.dart';

class InitNotificationAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    var notifications = await ApiService().notificationAPI.getAllNotifications();
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
    notifications.removeAt(notifications.indexWhere((element) => element.id == oldEntry.id));
    notifications.add(newEntry);
    return state.copyWith(notifications: notifications);
  }
}

class NotificationAddAction extends ReduxAction<AppState> {

  final NotificationModel model;

  NotificationAddAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().notificationAPI.addNotification(model);
    final models = await ApiService().notificationAPI.getAllNotifications();
    return state.copyWith(notifications: models);
  }
}

class RemoveNotificationAction extends ReduxAction<AppState> {

  final NotificationModel model;

  RemoveNotificationAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().notificationAPI.delete(model);
    final models = await ApiService().notificationAPI.getAllNotifications();
    return state.copyWith(notifications: models);
  }
}
