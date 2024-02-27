import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/feature/base/button/entry_buttons.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_data_card.dart';
import 'package:stelaris_ui/feature/dialogs/entry_add_dialog.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/functions.dart';

class LoreCard extends StatelessWidget {
  final ItemModel model;

  const LoreCard({
    required this.model,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableDataCard(
      title: Text(context.l10n.card_lore),
      buttonClick: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return EntryAddDialog(
              valueUpdate: (value) {
                final oldEntry = model;
                List<String> oldLores = List.of(oldEntry.lore ?? []);
                oldLores.add(value!);
                final newEntry = oldEntry.copyWith(lore: oldLores);
                StoreProvider.dispatch(
                  context,
                  UpdateItemAction(
                    oldEntry,
                    newEntry,
                  ),
                );
                Navigator.pop(context);
              },
              formFieldValidator: (value) {
                var input = value as String;
                return checkIfEmptyAndReturnErrorString(input, context);
              },
              title: context.l10n.button_add_new_line,
              autoFocus: true,
              formKey: GlobalKey<FormState>(),
            );
          },
        );
      },
      widgets: List<Widget>.generate(
        model.lore?.length ?? 0,
        (index) {
          final key = model.lore?[index];
          return ListTile(
            title: Text(key!),
            trailing: EntryButtons(
              editTitle: context.l10n.dialog_lore_edit_title,
              model: model,
              name: key,
              value: key,
              formFieldValidator: (value) {
                var input = value as String;
                return checkIfEmptyAndReturnErrorString(input, context);
              },
              delete: (ItemModel? value) {
                final oldEntry = model;
                List<String> oldLores = List.of(oldEntry.lore ?? []);
                oldLores.remove(key);
                final newEntry = oldEntry.copyWith(lore: oldLores);
                StoreProvider.dispatch(
                  context,
                  UpdateItemAction(
                    oldEntry,
                    newEntry,
                  ),
                );
              },
              update: (value, key) {
                final oldEntry = model;
                List<String> oldLores = List.of(oldEntry.lore ?? []);
                int index = oldLores.indexWhere(
                  (element) => identical(
                    element,
                    value,
                  ),
                );
                oldLores[index] = key!;
                final newEntry = oldEntry.copyWith(lore: oldLores);
                StoreProvider.dispatch(
                  context,
                  UpdateItemAction(
                    oldEntry,
                    newEntry,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
