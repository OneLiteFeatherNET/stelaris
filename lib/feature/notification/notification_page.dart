import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/notification/notification_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/dialogs/model_create_dialog.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// A widget that represents the notification management page.
///
/// The [NotificationPage] allows users to view, search, and manage
/// notifications through a [ModelPage]. It provides a dialog for creating
/// new notifications and handles the state management through Redux.
/// Tapping a notification navigates to its dedicated detail route, since a
/// notification has more editable fields (material, title, comment, frame
/// type) than would comfortably fit in a small dialog.
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, NotificationViewModel>(
      vm: () => NotificationVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitNotificationAction()),
      builder: (context, vm) {
        return ModelPage<NotificationModel>(
          mapToDataModelItem: (value) => _buildCardContent(context, value),
          mapToDeleteDialog: (value) =>
              createDeleteText(value.uiName, context),
          mapToDeleteSuccessfully: (value) {
            context.dispatch(NotificationRemoveAction(value));
            return true;
          },
          models: vm.models,
          matchesSearch: (model, query) =>
              model.uiName.toLowerCase().contains(query.toLowerCase()),
          nameSelector: (model) => model.uiName,
          matchesFilter: (model, filter) => true,
          onAdd: () => _openCreationDialog(context, vm.projectKey),
          onModelTap: (model) {
            context.dispatch(SelectedNotificationAction(model));
            context.go('${NavigationEntry.notifications.route}/detail');
          },
          hasMore: vm.hasNextPage,
          isLoadingMore: vm.isLoadingMore,
          onLoadMore: vm.hasNextPage && !vm.isLoadingMore
              ? () => context.dispatch(InitNotificationAction())
              : null,
        );
      },
    );
  }

  /// Builds the primary card content for a [NotificationModel]: its display
  /// name plus its configured material, if any.
  Widget _buildCardContent(BuildContext context, NotificationModel value) {
    final material = value.material;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.uiName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (material != null && material.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 12,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    material,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Opens a dialog for creating a new notification.
  void _openCreationDialog(BuildContext context, String projectKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModelCreateDialog(
          title: context.l10n.dialog_notification_create,
          projectNamespace: projectKey,
          onSubmit: (name, key) {
            final NotificationModel model = NotificationModel(
              uiName: name,
              key: key,
            );
            context.dispatchAndWait(NotificationAddAction(model));
            Navigator.pop(context, true);
          },
        );
      },
    );
  }
}
