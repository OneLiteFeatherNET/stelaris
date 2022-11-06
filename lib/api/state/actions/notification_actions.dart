import 'package:async_redux/async_redux.dart';

import '../../api_service.dart';
import '../../model/notification_model.dart';
import '../app_state.dart';

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
