import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/notification_model.dart';
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
    final List<NotificationModel> notifications =
        await ApiService().notificationAPI.getAll();
    if (notifications.isEmpty) return null;
    return state.copyWith(notifications: notifications);
  }

  InitNotificationAction();
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
    final NotificationModel added = await ApiService().notificationAPI.add(model);
    final models = List.of(state.notifications, growable: true);
    models.add(added);
    return state.copyWith(notifications: models, selectedNotification: added);
  }
}

class RemoveNotificationAction extends ReduxAction<AppState> {
  final NotificationModel model;

  RemoveNotificationAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final removedModel = await ApiService().notificationAPI.remove(model);
    final models = List.of(state.notifications, growable: true);
    models.remove(removedModel);
    return state.copyWith(notifications: models);
  }
}


class NotificationDatabaseUpdate extends ReduxAction<AppState> {

  NotificationDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedNotification == null) return null;
    final NotificationModel selected = state.selectedNotification!;
    final NotificationModel dbModel = await ApiService().notificationAPI.update(selected);
    final List<NotificationModel> models = List.of(state.notifications, growable: true);
    final int index = models.indexWhere((element) => element.id == selected.id);
    models.removeAt(index);
    models.insert(index, dbModel);
    return state.copyWith(notifications: models, selectedNotification: dbModel);
  }
}
