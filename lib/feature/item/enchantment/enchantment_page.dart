import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/item/item_enchantment_dto.dart';
import 'package:stelaris/api/state/actions/item/item_enchantment_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/item/enchantment_view_state.dart';
import 'package:stelaris/feature/dialogs/item_enchantments_dialog.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_actions.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_list.dart';
import 'package:stelaris/util/constants.dart';

class ItemEnchantmentPage extends StatefulWidget {
  const ItemEnchantmentPage({super.key});

  @override
  State<ItemEnchantmentPage> createState() => _ItemEnchantmentPageState();
}

class _ItemEnchantmentPageState extends State<ItemEnchantmentPage> {
  bool _isDeleteMode = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, EnchantmentView>(
      vm: () => EnchantmentViewFactory(),
      builder: (context, vm) {
        final enchantments = vm.getEnchantmentsViaGroup(vm.selected);
        final hasEnchantments = vm.selected.enchantments.hasItems;
        final canAddMoreEnchantments = vm.canAdd(vm.selected);

        // Automatically disable delete mode if no enchantments are present
        if (_isDeleteMode && !hasEnchantments) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _isDeleteMode = false;
            });
          });
        }

        return Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            children: [
              verticalSpacing10,
              verticalSpacing10,
              Expanded(
                child: EnchantmentList(
                  enchantments: enchantments,
                  selectedEnchantments: vm.selected.enchantments.items,
                  isDeleteMode: _isDeleteMode,
                  onLevelChanged: (enchantment, level) {
                  },
                  onEnchantmentDeleted: (enchantment) {
                    //context.dispatch(ItemEnchantmentDeleteAction(null));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveFunction(BuildContext context, EnchantmentView vm) {
    // Exit delete mode if active
    if (_isDeleteMode) {
      setState(() {
        _isDeleteMode = false;
      });
    }
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
