import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/model/notification_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/notification/notification_page_general.dart';
import 'package:stelaris/util/constants.dart';

class SelectedNotificationFactory
    extends VmFactory<AppState, NotificationGeneralPage, SelectedNotificationView> {
  SelectedNotificationFactory();

  @override
  SelectedNotificationView fromStore() =>
      SelectedNotificationView(selected: state.selectedNotification!);
}

class SelectedNotificationView extends Vm {
  SelectedNotificationView({required this.selected}) : super(equals: [selected]);

  final NotificationModel selected;
}
