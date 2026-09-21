import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/item/item_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/dialogs/model_create_dialog.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// A widget that represents the item management page.
///
/// The [ItemPage] allows users to view, search, and manage items through a
/// [ModelPage]. It provides a dialog for creating new items and handles the
/// state management through Redux. Tapping an item navigates to its
/// dedicated detail route, since its General/Meta/Enchantments/Lore tabs
/// need more room than a dialog can comfortably offer.
class ItemPage extends StatelessWidget {
  const ItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ItemViewModel>(
      vm: () => ItemVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitItemAction()),
      builder: (context, vm) {
        return ModelPage<ItemModel>(
          mapToDataModelItem: (value) => _buildCardContent(context, value),
          mapToDeleteDialog: (value) => createDeleteText(value.uiName, context),
          mapToDeleteSuccessfully: (value) {
            context.dispatch(ItemRemoveAction(value));
            return true;
          },
          models: vm.itemModels,
          matchesSearch: (model, query) =>
              model.uiName.toLowerCase().contains(query),
          nameSelector: (model) => model.uiName,
          keySelector: (model) => model.key ?? '',
          copyDialogTitle: context.l10n.dialog_item_copy,
          mapToCopySuccessfully: (value, result) {
            context.dispatch(ItemCopyAction(value, result));
            return true;
          },
          hasRelationshipData: (model) =>
              model.enchantments.items.isNotEmpty ||
              model.lore.items.isNotEmpty ||
              model.flags.items.isNotEmpty,
          projects: vm.projects,
          currentProject: vm.currentProject,
          matchesFilter: (model, filter) => true,
          onAdd: () => _openCreationDialog(context, vm.projectKey),
          onModelTap: (model) {
            context.dispatch(SelectedItemAction(model));
            context.go('${NavigationEntry.items.route}/detail');
          },
          onRefresh: () => context.dispatch(RefreshItemAction()),
          hasMore: vm.hasNextPage,
          isLoadingMore: vm.isLoadingMore,
          onLoadMore: vm.hasNextPage && !vm.isLoadingMore
              ? () => context.dispatch(InitItemAction())
              : null,
        );
      },
    );
  }

  /// Builds the primary card content for an [ItemModel]: its display name
  /// plus its configured material, if any.
  Widget _buildCardContent(BuildContext context, ItemModel value) {
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
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
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

  void _openCreationDialog(BuildContext context, String projectKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModelCreateDialog(
          title: context.l10n.dialog_item_create,
          projectNamespace: projectKey,
          onSubmit: (name, key) {
            final model = ItemModel(uiName: name, key: key);
            context.dispatch(ItemAddAction(model));
            Navigator.pop(context, true);
          },
        );
      },
    );
  }
}
