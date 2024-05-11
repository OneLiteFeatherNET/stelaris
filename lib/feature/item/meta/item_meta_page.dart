import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/state/factory/item/selected_item_state.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/item/meta/enchantment_card.dart';
import 'package:stelaris_ui/feature/item/meta/flag_card.dart';
import 'package:stelaris_ui/feature/item/item_reducer.dart';
import 'package:stelaris_ui/util/constants.dart';

class ItemMetaPage extends StatelessWidget with DropDownItemReducer {

  ItemMetaPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedItemView>(
      vm: () => SelectedItemFactory(),
      builder: (context, vm) {
        return Stack(
          children: [
            SingleChildScrollView(
              child: Wrap(
                clipBehavior: Clip.hardEdge,
                children: [
                  verticalSpacing10,
                  FlagCard(model: vm.selected),
                  verticalSpacing10,
                  EnchantmentCard(model: vm.selected),
                ],
              ),
            ),
            SaveButton(
              callback: () => context.dispatch(ItemDatabaseUpdate()),
            )
          ],
        );
      },
    );
  }
}
