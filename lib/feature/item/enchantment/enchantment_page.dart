import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/item/item_enchantment_dto.dart';
import 'package:stelaris/api/state/actions/item/item_enchantment_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/item/enchantment_view_state.dart';
import 'package:stelaris/feature/dialogs/item_enchantments_dialog.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_list.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

class ItemEnchantmentPage extends StatefulWidget {
  const ItemEnchantmentPage({super.key});

  @override
  State<ItemEnchantmentPage> createState() => _ItemEnchantmentPageState();
}

class _ItemEnchantmentPageState extends State<ItemEnchantmentPage> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, EnchantmentView>(
      vm: () => EnchantmentViewFactory(),
      builder: (context, vm) {
        return Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            children: [
              verticalSpacing25,
              Align(
                alignment: Alignment.center,
                child: ActionChip(
                  avatar: const Icon(Icons.add),
                  label: Text(context.l10n.button_add),
                  onPressed: () => _showAddEnchantmentDialog(context, vm),
                ),
              ),
              verticalSpacing10,
              Expanded(
                child: EnchantmentList(
                  activeEnchantments: vm.activeEnchantments,
                  selectedEnchantmentMap: vm.selectedEnchantmentMap,
                  onLevelChanged: (enchantment, level) {
                    // Handle level change
                  },
                  onEnchantmentDeleted: (enchantment) {

                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddEnchantmentDialog(BuildContext context, EnchantmentView vm) {
    showDialog(
      context: context,
      builder: (context) => ItemEnchantmentAddDialog(
        addEnchantmentCallback: (enchantment, level) {
          final ItemEnchantmentDto dto = ItemEnchantmentDto(
            name: enchantment.minecraftValue,
            level: level,
          );
          context.dispatch(ItemEnchantmentAddAction(dto));
          Navigator.of(context).pop();
        },
        model: vm.selected,
      ),
    );
  }
}
