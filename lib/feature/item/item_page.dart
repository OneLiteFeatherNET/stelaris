import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/item/item_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';
import 'package:stelaris/feature/model/model_create.dart';
import 'package:stelaris/feature/model/model_page.dart';
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
          entry: NavigationEntry.items,
          mapToDataModelItem: (value) =>
              _buildCardContent(context, vm.projectKey, value),
          deleteTitle: context.l10n.dialog_item_delete_title,
          deleteWarning: context.l10n.delete_dialog_related_item,
          mapToDeleteSuccessfully: (value) {
            context.dispatch(ItemRemoveAction(value));
            return true;
          },
          models: vm.itemModels,
          nameSelector: (model) => model.uiName,
          keySelector: (model) => model.key ?? '',
          projectKey: vm.projectKey,
          matchesFilter: (model, filter) => true,
          onAdd: () => openModelCreateDialog(
            context,
            NavigationEntry.items,
            vm.projectKey,
          ),
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
  /// plus its namespaced key (e.g. `manis:test`), derived client-side
  /// from the current project's key and the model's local [ItemModel.key].
  Widget _buildCardContent(
    BuildContext context,
    String projectKey,
    ItemModel value,
  ) {
    final key = value.key;
    final namespacedKey = key != null && key.isNotEmpty
        ? '$projectKey:$key'
        : null;
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
        if (namespacedKey != null) ...[
          const SizedBox(height: 6),
          InfoChip(icon: Icons.vpn_key_outlined, text: namespacedKey),
        ],
      ],
    );
  }

}
