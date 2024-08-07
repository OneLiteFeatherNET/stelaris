import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/state/factory/item/enchantment_view_state.dart';
import 'package:stelaris_ui/feature/item/enchantment/enchantment_actions.dart';
import 'package:stelaris_ui/feature/item/enchantment/enchantment_dot_page.dart';
import 'package:stelaris_ui/util/constants.dart';

class EnchantmentPage extends StatelessWidget {
  const EnchantmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, EnchantmentView>(
      vm: () => EnchantmentViewFactory(),
      builder: (context, vm) {
        return Column(
          children: [
            verticalSpacing10,
            EnchantmentActions(
              resetFunction: () => resetFunction(context, vm),
              saveFunction: () => saveFunction(context, vm),
            ),
            verticalSpacing10,
            Expanded(
              child: EnchantmentDotPage(
                enchantmentView: vm,
                rawEnchantments: vm.getEnchantmentsViaGroup(vm.selected),
              ),
            )
          ],
        );
      },
    );
  }

  void resetFunction(BuildContext context, EnchantmentView vm) {}

  void saveFunction(BuildContext context, EnchantmentView vm) {}
}
