import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/feature/notification/notification_page_general.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The detail view reached by tapping a notification card in [NotificationPage].
///
/// Shows the shared [ModelDetailShell] header row with its actions, with the existing
/// [NotificationGeneralPage] form below it unchanged.
class NotificationDetailPage extends StatelessWidget {
  const NotificationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _NotificationTitleView>(
      vm: () => _NotificationTitleFactory(),
      builder: (context, vm) => ModelDetailShell(
        entry: NavigationEntry.notifications,
        title: vm.title,
        actions: [
          ModelDetailActions<NotificationModel>(
            entry: NavigationEntry.notifications,
            selectModel: (state) => state.selectedNotification,
            nameSelector: (model) => model.uiName,
            keySelector: (model) => model.key ?? '',
            deleteTitle: context.l10n.dialog_notification_delete_title,
            removeAction: NotificationRemoveAction.new,
          ),
        ],
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
