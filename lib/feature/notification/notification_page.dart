import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/notification/notification_vm_state.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/base/model_text.dart';
import 'package:stelaris/feature/base/paginated_model_list.dart';
import 'package:stelaris/feature/dialogs/model_create_dialog.dart';
import 'package:stelaris/feature/notification/notification_page_general.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/l10n_ext.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, NotificationViewModel>(
      vm: () => NotificationVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitNotificationAction()),
      builder: (context, vm) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaginatedModelList<NotificationModel>(
              mapToDataModelItem: (value) =>
                  TextWidget(displayName: value.uiName),
              openFunction: () => _openCreationDialog(context, vm.projectKey),
              selectedItem: vm.selected,
              mapToDeleteDialog: (value) =>
                  createDeleteText(value.uiName, context),
              mapToDeleteSuccessfully: (value) {
                context.dispatch(NotificationRemoveAction(value));
                return true;
              },
              callFunction: (model) =>
                  context.dispatch(SelectedNotificationAction(model)),
              models: vm.models,
              compareFunction: (model) => vm.isSelectedItem(model),
              hasMore: vm.hasNextPage,
              isLoadingMore: vm.isLoadingMore,
              onLoadMore: vm.hasNextPage && !vm.isLoadingMore
                  ? () => context.dispatch(InitNotificationAction())
                  : null,
            ),
            _mapModelToWidget(context, vm.selected),
          ],
        );
      },
    );
  }

  void _openCreationDialog(BuildContext context, String projectKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModelCreateDialog(
          title: context.l10n.dialog_notification_create,
          projectNamespace: projectKey,
          onSubmit: (name, key) {
            // TODO: pass key once stelaris_models has key support
            final NotificationModel model = NotificationModel(uiName: name);
            context.dispatchAndWait(NotificationAddAction(model));
            Navigator.pop(context, true);
          },
        );
      },
    );
  }

  /// Maps the given [NotificationModel] to the right widget.
  /// If the model is null, it returns an [Expanded] widget with an [EmptyDataWidget].
  /// Otherwise, it returns an instance of [NotificationGeneralPage].
  Widget _mapModelToWidget(BuildContext context, NotificationModel? model) {
    if (model == null) {
      return Expanded(
        child: EmptyDataWidget.standard(
          header: context.l10n.empty_data_header,
          subHeader: context.l10n.empty_data_subHeader,
        ),
      );
    }
    return const NotificationGeneralPage();
  }
}
