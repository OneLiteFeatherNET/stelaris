import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/util/default.dart';

import '../../api_service.dart';
import '../../model/notification_model.dart';
import '../app_state.dart';

class InitNotificationAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    // var items = await ApiService().itemApi.getAllItems();
    return state.copyWith(notifications: [firstNotificationModel, secondNotificationModel]);
  }

  InitNotificationAction();
}


class UpdateNotificationAction extends ReduxAction<AppState> {
  final NotificationModel notification;

  UpdateNotificationAction(this.notification);

  @override
  Future<AppState?> reduce() async {
    var notifications = await ApiService().notificationAPI.getAllNotifications();
    return state.copyWith(notifications: notifications);
  }
}

class InputNotificationAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    var notifications = await ApiService().notificationAPI.getAllNotifications();
    return state.copyWith(notifications: notifications);
  }

  InputNotificationAction();
}

class RemoveNotificationAction extends ReduxAction<AppState> {

  final NotificationModel model;

  RemoveNotificationAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final notifications = List.of(state.notifications, growable: true);
    notifications.remove(model);
    return state.copyWith(notifications: notifications);
  }
}
