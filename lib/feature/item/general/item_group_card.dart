import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/feature/base/button/cancel_button.dart';
import 'package:stelaris/feature/base/cards/dropdown_card.dart';
import 'package:stelaris/feature/item/item_group.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';

class ItemGroupCard extends StatelessWidget {
  const ItemGroupCard({
    required this.model,
    required this.groupKey,
    super.key,
  });

  final ItemModel model;
  final GlobalKey<FormState> groupKey;

  @override
  Widget build(BuildContext context) {
    return DropdownCard<ItemGroup, ItemModel>(
      display: context.l10n.card_group,
      currentValue: model,
      formKey: groupKey,
      items: getGroupItems(),
      valueUpdate: (ItemGroup? value) {
        if (value == null) return;
        final ItemGroup selected = value;
        if (selected.hasSameGroup(model.group)) return;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Group change', textAlign: TextAlign.center,),
              contentPadding: dialogPadding,
              content: const SizedBox(
                height: 75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A change of the group will reset each selected enchantment',
                    ),
                    heightTen,
                    Text(
                      'Do you want to proceed?',
                    ),
                  ],
                ),
              ),
              actions: [
                CancelButton(
                  callback: () {
                    if (groupKey.currentState == null) return;
                    groupKey.currentState!.reset();
                  },
                ),
                FilledButton(
                  child: Text(context.l10n.button_yes),
                  onPressed: () {
                    final newEntry = model.copyWith(
                      group: value,
                      enchantments: {},
                    );
                    context.dispatch(UpdateItemAction(newEntry));
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
      defaultValue: ((value) => model.group),
    );
  }
}
