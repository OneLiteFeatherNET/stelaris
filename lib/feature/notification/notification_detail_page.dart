import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/feature/notification/notification_page_general.dart';

/// The detail view reached by tapping a notification card in [NotificationPage].
///
/// Shows the shared [ModelDetailShell] back row, with the existing
/// [NotificationGeneralPage] form below it unchanged.
class NotificationDetailPage extends StatelessWidget {
  const NotificationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _NotificationTitleView>(
      vm: () => _NotificationTitleFactory(),
      builder: (context, vm) => ModelDetailShell(
        parentRoute: NavigationEntry.notifications.route,
        title: vm.title,
        body: const NotificationGeneralPage(),
      ),
    );
  }
}

class _NotificationTitleView extends Vm {
  _NotificationTitleView({required this.title}) : super(equals: [title]);

  final String? title;
}

class _NotificationTitleFactory
    extends VmFactory<AppState, NotificationDetailPage, _NotificationTitleView> {
  @override
  _NotificationTitleView fromStore() =>
      _NotificationTitleView(title: state.selectedNotification?.uiName);
}
