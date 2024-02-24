import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/state/actions/font_actions.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_data_card.dart';
import 'package:stelaris_ui/feature/dialogs/abort_add_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/delete_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/entry_add_dialog.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class CharCard extends StatelessWidget {
  final FontModel model;

  const CharCard({
    required this.model,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableDataCard(
      title: Text(context.l10n.card_chars),
      buttonClick: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return EntryAddDialog(
              title: Text(
                context.l10n.dialog_char_title,
                textAlign: TextAlign.center,
              ),
              forceClose: true,
              controller: TextEditingController(),
              formFieldValidator: (value) {
                String input = value as String;

                if (input.trim().isEmpty) {
                  return context.l10n.error_card_empty;
                }

                if (!input.startsWith("\\u")) {
                  return context.l10n.error_not_unicode_start;
                }

                if (input.length > 6) {
                  return context.l10n.error_not_unicode;
                }
                return null;
              },
              valueUpdate: (value) {
                if (model.chars != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AbortAddDialog(
                        title: context.l10n.dialog_abort_chars_add,
                        content:
                            '${context.l10n.dialog_abort_chars_text} $value',
                      );
                    },
                  );
                  return;
                }
                final oldEntry = model;
                List<String> chars = List.of(oldEntry.chars ?? []);
                chars.add(value);
                final newEntry = oldEntry.copyWith(chars: chars);
                StoreProvider.dispatch(
                  context,
                  UpdateFontAction(
                    oldEntry,
                    newEntry,
                  ),
                );
              },
            );
          },
        );
      },
      widgets: List<Widget>.generate(
        model.chars?.length ?? 0,
        (index) {
          final key = model.chars![index];
          return ListTile(
            title: Text(key),
            trailing: IconButton(
              icon: deleteIcon,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return DeleteDialog<String>(
                      title: Text(context.l10n.dialog_delete_confirm),
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
                      successfully: (value) {
                        final oldEntry = model;
                        List<String> chars = List.of(model.chars ?? []);
                        chars.remove(key);
                        final newEntry = oldEntry.copyWith(chars: chars);
                        StoreProvider.dispatch(
                          context,
                          UpdateFontAction(
                            oldEntry,
                            newEntry,
                          ),
                        );
                        return true;
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
