import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/item/item_enchantment_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/item/enchantment_view_state.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/base/skeleton_bar.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/item/enchantment/dialog/item_enchantments_dialog.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_list.dart';
import 'package:stelaris/feature/item/enchantment/item_group_selector.dart';
import 'package:stelaris/feature/item/item_tab_loading.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/settled_after_transitions.dart';

class ItemEnchantmentPage extends StatefulWidget {
  const ItemEnchantmentPage({super.key});

  @override
  State<ItemEnchantmentPage> createState() => _ItemEnchantmentPageState();
}

class _ItemEnchantmentPageState extends State<ItemEnchantmentPage>
    with
        AutomaticKeepAliveClientMixin,
        SettledAfterTransitions,
        ItemTabLoading {
  @override
  ReduxAction<AppState> createLoadAction() => ItemEnchantmentFetchAction();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StoreConnector<AppState, EnchantmentView>(
      vm: () => EnchantmentViewFactory(),
      onDidChange: (context, store, vm) => selectedItemChanged(vm.selected.id),
      builder: (context, vm) {
        final pending = !settled || vm.loading;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader.small(
                title: context.l10n.enchantment_page_title(
                  vm.selected.enchantments.totalItems,
                ),
                actions: [
                  ItemGroupSelector(model: vm.selected),
                  PageHeaderAction(
                    icon: const Icon(Icons.add),
                    label: context.l10n.button_add,
                    primary: true,
                    loading: pending,
                    onPressed: () => _showAddEnchantmentDialog(context, vm),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: pending
                    ? const _EnchantmentSkeleton()
                    : EnchantmentList(
                        view: vm,
                        selectedEnchantmentMap: vm.selectedEnchantmentMap,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddEnchantmentDialog(BuildContext context, EnchantmentView vm) {
    if (vm.selectedEnchantmentMap.length >= vm.enchantments.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        InfoBarFactory().create(context.l10n.tooltip_item_enchantment_all_set),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => ItemEnchantmentAddDialog(view: vm),
    );
  }
}

/// Stands in for the enchantment list while it loads: cards in the shape of
/// an [EnchantmentItem], with bars for its name and level.
class _EnchantmentSkeleton extends StatelessWidget {
  const _EnchantmentSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const Key('enchantment_skeleton'),
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 4,
      itemBuilder: (context, index) => const Card(
        margin: EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: SkeletonBar(widthFactor: 0.4, height: 16),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 8),
            child: SkeletonBar(widthFactor: 0.2, height: 12),
          ),
        ),
      ),
    );
  }
}
