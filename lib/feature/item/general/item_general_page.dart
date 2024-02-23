import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/base/cards/text_input_card.dart';
import 'package:stelaris_ui/feature/item/enchantment_reducer.dart';
import 'package:stelaris_ui/feature/item/general/group_card.dart';
import 'package:stelaris_ui/feature/item/item_group.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/functions.dart';

const List<ItemGroup> values = ItemGroup.values;

List<DropdownMenuItem<ItemGroup>> getItems() {
  return List.generate(
      values.length,
      (index) => DropdownMenuItem(
            value: values[index],
            child: Text(values[index].display),
          ));
}

class ItemGeneralPage extends StatelessWidget with EnchantmentReducer {
  final ItemModel model;

  ItemGeneralPage({
    required this.model,
    super.key,
  });

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                currentValue: model.name ?? emptyString,
                formatter: [FilteringTextInputFormatter.allow(stringPattern)],
                valueUpdate: (value) {
                  if (value == model.name) return;
                  final oldModel = model;
                  final newEntry = oldModel.copyWith(name: value);
                  StoreProvider.dispatch(
                      context, UpdateItemAction(oldModel, newEntry));
                },
                formValidator: (value) {
                  var input = value as String;
                  return checkIfEmptyAndReturnErrorString(input, context);
                },
                maxLength: 30,
              ),
              TextInputCard<String>(
                display: context.l10n.card_description,
                currentValue: model.description ?? emptyString,
                valueUpdate: (value) {
                  if (value == model.description) return;
                  final oldModel = model;
                  final newEntry = oldModel.copyWith(description: value);
                  StoreProvider.dispatch(
                      context, UpdateItemAction(oldModel, newEntry));
                },
                maxLength: 30,
              ),
              GroupCard(model: model, values: values,),
              TextInputCard<String>(
                display: context.l10n.card_material,
                hintText: defaultMaterial,
                currentValue: model.material ?? emptyString,
                valueUpdate: (value) {
                  if (value == model.material) return;
                  final oldModel = model;
                  final newEntry = oldModel.copyWith(material: value);
                  StoreProvider.dispatch(
                      context, UpdateItemAction(oldModel, newEntry));
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
                currentValue: model.displayName ?? emptyString,
                valueUpdate: (value) {
                  if (value == model.displayName) return;
                  final oldModel = model;
                  final newEntry = oldModel.copyWith(displayName: value);
                    StoreProvider.dispatch(
                        context, UpdateItemAction(oldModel, newEntry));
                },
                maxLength: 30,
              ),
              TextInputCard<int>(
                tooltipMessage: context.l10n.tooltip_model_data,
                display: context.l10n.card_model_data,
                currentValue:
                    model.customModelId?.toString() ?? zeroString,
                valueUpdate: (value) {
                  if (value == model.customModelId) return;
                  final oldModel = model;
                  final newID = value ?? 0;
                  final newEntry = oldModel.copyWith(customModelId: newID);
                  StoreProvider.dispatch(
                      context, UpdateItemAction(oldModel, newEntry));
                },
                maxLength: 30,
                inputType: numberInput,
                formatter: [FilteringTextInputFormatter.allow(numberPattern)],
                isNumber: true,
              ),
              TextInputCard<int>(
                display: context.l10n.card_amount,
                currentValue: model.amount?.toString() ?? zeroString,
                valueUpdate: (value) {
                  if (value == model.amount) return;
                  final oldModel = model;
                  final newAmount = value ?? 0;
                  final newEntry = oldModel.copyWith(amount: newAmount);
                  StoreProvider.dispatch(
                      context, UpdateItemAction(oldModel, newEntry));
                },
                inputType: numberInput,
                formatter: [FilteringTextInputFormatter.allow(numberPattern)],
                formValidator: (value) {
                  if (value == null) return null;
                  String input = value as String;
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
        SaveButton(callback: () {
          if (!_key.currentState!.validate()) return;
          ApiService().itemApi.update(model);
        })
      ],
    );
  }
}
