import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/util/minecraft/item_flag.dart';
import 'package:stelaris_ui/feature/base/button/delete_entry_button.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_data_card.dart';
import 'package:stelaris_ui/feature/dialogs/abort_add_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/enum_add_dialog.dart';
import 'package:stelaris_ui/feature/item/item_reducer.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class FlagCard extends StatelessWidget with DropDownItemReducer {
  final ItemModel model;
  const FlagCard({
    required this.model,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> flags = model.flags == null ? [] : model.flags!.toList();
    return ExpandableDataCard(
      title: Text(context.l10n.card_flags),
      buttonClick: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            if (flags.length == ItemFlag.values.length) {
              return AbortAddDialog(
                  title: context.l10n.dialog_abort_flags_title,
                  content: context.l10n.dialog_abort_flags);
            }
            return EnumAddDialog<ItemFlag>(
                title: Text(context.l10n.enum_dialog_flags,
                    textAlign: TextAlign.center),
                items: reduceFlags(model),
                valueUpdate: (value) {
                  final oldEntry = model;
                  Set<String> flags = Set.of(oldEntry.flags ?? {});
                  flags.add(value!.minestomValue);
                  final newEntry = oldEntry.copyWith(flags: flags);
                  StoreProvider.dispatch(
                    context,
                    UpdateItemAction(
                      oldEntry,
                      newEntry,
                    ),
                  );
                  Navigator.pop(context);
                });
          },
        );
      },
      widgets: List<Widget>.generate(
        flags.length,
        (index) {
          final key = flags[index];
          return ListTile(
              title: Text(key),
              trailing: DeleteEntryButton<String>(
                title: context.l10n.dialog_delete_confirm,
                header: [
                  TextSpan(
                    text: context.l10n.delete_dialog_first_line,
                    style: whiteStyle,
                  ),
                  TextSpan(
                    text: key,
                    style: redStyle,
                  ),
                  TextSpan(
                    text: context.l10n.delete_dialog_entry,
                    style: whiteStyle,
                  ),
                ],
                value: key,
                mapToDeleteSuccessfully: (value) {
                  final oldEntry = model;
                  Set<String> oldFlags = Set.of(oldEntry.flags ?? {});
                  oldFlags.remove(key);
                  final newEntry = oldEntry.copyWith(flags: oldFlags);
                  StoreProvider.dispatch(
                    context,
                    UpdateItemAction(
                      oldEntry,
                      newEntry,
                    ),
                  );
                  return true;
                },
              ));
        },
      ),
    );
  }
}
