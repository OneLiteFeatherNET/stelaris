import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/feature/base/cards/dropdown_card.dart';
import 'package:stelaris_ui/feature/item/enchantment_reducer.dart';
import 'package:stelaris_ui/feature/item/item_group.dart';
import 'package:stelaris_ui/feature/item/item_group_change_dialog.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class GroupCard extends StatelessWidget with EnchantmentReducer {
  final List<ItemGroup> values;
  final ItemModel model;

  GroupCard({super.key, required this.values, required this.model,});

  final _groupKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return DropdownCard<ItemGroup, ItemModel>(
      display: context.l10n.card_group,
      currentValue: model,
      formKey: _groupKey,
      items: getItems(),
      valueUpdate: (ItemGroup? value) {
        if (identical(value!.display, model.group)) return;

        var list = getRemoveItems(model, value);

        if (list.isNotEmpty) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return ItemGroupChangeDialog(
                  title: Text(
                    context.l10n.dialog_group_change,
                    textAlign: TextAlign.center,
                  ),
                  header: [
                    TextSpan(
                        text: context.l10n.dialog_group_change_text,
                        style: whiteStyle,),
                  ],
                  function: (value) {
                    return true;
                  },
                );
              }).then((result) {
            if (result == null) return;

            if (result == true) {
              final oldEnchantments =
              Map.of(model.enchantments!);

              for (var enchantment in list) {
                oldEnchantments.remove(enchantment);
              }
              final newEntry = model.copyWith(
                  group: value.display,
                  enchantments: oldEnchantments);
              StoreProvider.dispatch(
                  context, UpdateItemAction(model, newEntry,),);
            } else {
              _groupKey.currentState!.reset();
            }
          });
        } else {
          final newEntry =
          model.copyWith(group: value.display);
          StoreProvider.dispatch(
            context,
            UpdateItemAction(model, newEntry),
          );
        }
      },
      defaultValue: getDefaultValue,
    );
  }

  List<DropdownMenuItem<ItemGroup>> getItems() {
    return values
        .map((e) => DropdownMenuItem(
      value: e,
      child: Text(e.display),
    ))
        .toList();
  }

  ItemGroup getDefaultValue(ItemModel value) {
    if (value.group == null) {
      return ItemGroup.misc;
    }
    return values.firstWhere((element) => element.display == value.group);
  }
}
