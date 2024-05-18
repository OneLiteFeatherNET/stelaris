import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/feature/base/button/entry_buttons.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_data_card.dart';
import 'package:stelaris_ui/feature/dialogs/abort_add_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/item_enchantments_dialog.dart';
import 'package:stelaris_ui/feature/item/enchantment_reducer.dart';
import 'package:stelaris_ui/util/l10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/functions.dart';

class EnchantmentCard extends StatelessWidget with EnchantmentReducer {
  final ItemModel model;

  EnchantmentCard({
    required this.model,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ExpandableDataCard(
          title: Text(context.l10n.card_enchantments),
          buttonClick: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                if (model.enchantments != null && !canAdd(model)) {
                  return AbortAddDialog(
                    title: context.l10n.dialog_abort_enchantment_title,
                    content: context.l10n.dialog_abort_enchantments,
                  );
                }
                final oldEntry = model;
                return ItemEnchantmentAddDialog(
                  model: model,
                  formFieldValidator: (value) {
                    final input = value as String;

                    return checkIfEmptyAndReturnErrorString(input, context);
                  },
                  addEnchantmentCallback: (selected, level) {
                    final oldEnchantments =
                        Map<String, int>.of(oldEntry.enchantments ?? {});
                    oldEnchantments[selected.minecraftValue] = level;
                    final newEntry =
                        oldEntry.copyWith(enchantments: oldEnchantments);
                    Navigator.pop(context);
                    context.dispatch(UpdateItemAction(newEntry));
                  },
                );
              },
            );
          },
          widgets: List<Widget>.generate(
            model.enchantments?.length ?? 0,
            (index) {
              final key = model.enchantments?.keys.elementAt(index);
              final value = model.enchantments?.values.elementAt(index);
              return ListTile(
                title: Text('$key, Level: $value'),
                trailing: EntryButtons(
                  editTitle: context.l10n.dialog_level_title,
                  model: model,
                  name: key,
                  value: value.toString(),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(numberPattern)
                  ],
                  formFieldValidator: (value) {
                    final input = value as String;

                    return checkIfEmptyAndReturnErrorString(input, context);
                  },
                  delete: (ItemModel? value) {
                    final oldEntry = model;
                    final oldEnchantments =
                        Map<String, int>.of(oldEntry.enchantments ?? {});
                    oldEnchantments.remove(key);
                    final newEntry =
                        oldEntry.copyWith(enchantments: oldEnchantments);
                    context.dispatch(UpdateItemAction(newEntry));
                  },
                  update: (value, key) {
                    final oldEntry = model;
                    final oldEnchantments =
                        Map<String, int>.from(oldEntry.enchantments ?? {});
                    oldEnchantments[value!] = int.parse(key!);
                    final newEntry =
                        oldEntry.copyWith(enchantments: oldEnchantments);
                    context.dispatch(UpdateItemAction(newEntry));
                  },
                ),
              );
            },
          ),
        ),
        SaveButton(
          callback: () => context.dispatch(ItemDatabaseUpdate()),
        ),
      ],
    );
  }
}
