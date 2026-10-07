import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/item/item_enchantment_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/item/enchantment_view_state.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/item/enchantment/dialog/item_enchantments_dialog.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_list.dart';
import 'package:stelaris/feature/item/enchantment/item_group_selector.dart';
import 'package:stelaris/util/l10n_ext.dart';

class ItemEnchantmentPage extends StatelessWidget {
  const ItemEnchantmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, EnchantmentView>(
      vm: () => EnchantmentViewFactory(),
      onInit: (store) => store.dispatchAndWait(ItemEnchantmentFetchAction()),
      builder: (context, vm) {
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
                    onPressed: () => _showAddEnchantmentDialog(context, vm),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: EnchantmentList(
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
