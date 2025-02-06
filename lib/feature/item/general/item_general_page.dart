import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/item/selected_item_state.dart';
import 'package:stelaris/feature/base/button/save_button.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';
import 'package:stelaris/feature/item/enchantment_reducer.dart';
import 'package:stelaris/feature/item/general/item_group_card.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';

class ItemGeneralPage extends StatelessWidget with EnchantmentReducer {
  ItemGeneralPage({
    super.key,
  });

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedItemView>(
      vm: () => SelectedItemFactory<ItemGeneralPage>(),
      builder: (context, vm) {
        return Stack(
          children: [
            Form(
              autovalidateMode: AutovalidateMode.always,
              key: _key,
              child: Wrap(
                children: [
                  TextInputCard<String>(
                    display: context.l10n.card_name,
                    tooltipMessage: context.l10n.tooltip_name,
                    currentValue: vm.selected.name ?? emptyString,
                    formatter: [
                      FilteringTextInputFormatter.allow(stringPattern)
                    ],
                    valueUpdate: (value) {
                      if (value == vm.selected.name) return;
                      final oldModel = vm.selected;
                      final newEntry = oldModel.copyWith(name: value);
                      context.dispatch(UpdateItemAction(newEntry));
                    },
                    formValidator: (value) {
                      final String input = value as String;
                      return checkIfEmptyAndReturnErrorString(input, context);
                    },
                    maxLength: 30,
                  ),
                  TextInputCard<String>(
                    display: context.l10n.card_description,
                    currentValue: vm.selected.description ?? emptyString,
                    valueUpdate: (value) {
                      if (value == vm.selected.description) return;
                      final oldModel = vm.selected;
                      final newEntry = oldModel.copyWith(description: value);
                      context.dispatch(UpdateItemAction(newEntry));
                    },
                    maxLength: 30,
                  ),
                  ItemGroupCard(
                    model: vm.selected,
                    groupKey: GlobalKey<FormState>(),
                  ),
                  TextInputCard<String>(
                    display: context.l10n.card_material,
                    hintText: defaultMaterial,
                    currentValue: vm.selected.material ?? emptyString,
                    valueUpdate: (value) {
                      if (value == vm.selected.material) return;
                      final oldModel = vm.selected;
                      final newEntry = oldModel.copyWith(material: value);
                      context.dispatch(UpdateItemAction(newEntry));
                    },
                    formValidator: (value) {
                      if (value == null) return null;
                      if (!minecraftPattern.hasMatch(value)) {
                        return context.l10n.input_validation_material;
                      }
                      return null;
                    },
                    maxLength: 30,
                  ),
                  TextInputCard<String>(
                    tooltipMessage: context.l10n.tooltip_displayname,
                    display: context.l10n.card_display_name,
                    currentValue: vm.selected.displayName ?? emptyString,
                    valueUpdate: (value) {
                      if (value == vm.selected.displayName) return;
                      final oldModel = vm.selected;
                      final newEntry = oldModel.copyWith(displayName: value);
                      context.dispatch(UpdateItemAction(newEntry));
                    },
                    maxLength: 30,
                  ),
                  TextInputCard<int>(
                    tooltipMessage: context.l10n.tooltip_model_data,
                    display: context.l10n.card_model_data,
                    currentValue:
                        vm.selected.customModelId?.toString() ?? zeroString,
                    valueUpdate: (value) {
                      final newValue = int.tryParse(value) ?? 0;
                      if (newValue == vm.selected.customModelId) return;
                      final oldModel = vm.selected;
                      final newEntry =
                          oldModel.copyWith(customModelId: newValue);
                      context.dispatch(UpdateItemAction(newEntry));
                    },
                    maxLength: 30,
                    inputType: numberInput,
                    formatter: [
                      FilteringTextInputFormatter.allow(numberPattern)
                    ],
                    isNumber: true,
                  ),
                  TextInputCard<int>(
                    display: context.l10n.card_amount,
                    currentValue: vm.selected.amount?.toString() ?? zeroString,
                    valueUpdate: (value) {
                      final updatedValue = int.tryParse(value) ?? 0;
                      if (updatedValue == vm.selected.amount) return;
                      final oldModel = vm.selected;
                      final newEntry = oldModel.copyWith(amount: updatedValue);
                      context.dispatch(UpdateItemAction(newEntry));
                    },
                    inputType: numberInput,
                    formatter: [
                      FilteringTextInputFormatter.allow(numberPattern)
                    ],
                    formValidator: (value) {
                      if (value == null) return null;
                      final String input = value as String;
                      if (input.trim().isEmpty) {
                        return context.l10n.error_card_empty;
                      }

                      if (int.parse(input) > maxItemSize) {
                        return context.l10n.card_amount_to_high;
                      }
                      return null;
                    },
                    maxLength: 30,
                    isNumber: true,
                  ),
                ],
              ),
            ),
            SaveButton(
              callback: () {
                if (!_key.currentState!.validate()) return;
                context.dispatch(ItemDatabaseUpdate());
              },
            )
          ],
        );
      },
    );
  }
}
