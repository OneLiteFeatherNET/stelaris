import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/state/actions/notification_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/notification/notification_page.dart';

class NotificationVmFactory
    extends VmFactory<AppState, NotificationPage, NotificationViewModel> {
  NotificationVmFactory();

  Future<void> updateSelectedEntry(NotificationModel model) async {
    dispatchAsync(SelectedNotificationAction(model));
  }

  Future<void> removeSelectedEntry(NotificationModel model) async {
    dispatchAsync(RemoveSelectNotificationAction(model));
  }

  @override
  NotificationViewModel? fromStore() => NotificationViewModel(
      models: state.notifications, selected: state.selectedNotification);
}

class NotificationViewModel extends Vm {
  final List<NotificationModel> models;
  final NotificationModel? selected;

  NotificationViewModel({
    required this.models,
    required this.selected,
  }) : super(equals: [models, selected]);

  bool isSelectedItem(NotificationModel model) {
    return selected != null && selected.hashCode == model.hashCode;
  }
}
