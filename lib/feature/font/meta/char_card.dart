import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/actions/font_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/state/factory/font/selected_font_state.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_data_card.dart';
import 'package:stelaris_ui/feature/dialogs/abort_add_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/delete_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris_ui/util/l10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class CharCard extends StatelessWidget {
  const CharCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedFontView>(
      vm: () => SelectedFontFactory(),
      builder: (context, vm) {
        return ExpandableDataCard(
          title: Text(context.l10n.card_chars),
          buttonClick: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return EntryUpdateDialog(
                  title: context.l10n.dialog_char_title,
                  formFieldValidator: (value) =>
                      _validateCharInput(context, value as String),
                  valueUpdate: (value) {
                    if (vm.selected.chars != null && vm.selected.chars!.contains(value)) {
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
                    final oldEntry = vm.selected;
                    final List<String> chars = List.of(oldEntry.chars ?? []);
                    chars.add(value!);
                    final newEntry = oldEntry.copyWith(chars: chars);
                    context.dispatch(UpdateFontAction(newEntry));
                    Navigator.of(context).pop(true);
                  },
                  formKey: GlobalKey<FormState>(),
                );
              },
            );
          },
          widgets: List<Widget>.generate(
            vm.selected.chars?.length ?? 0,
            (index) {
              final key = vm.selected.chars![index];
              return ListTile(
                title: Text(key),
                leading: Text(convertToEmoji(key)),
                trailing: IconButton(
                  icon: deleteIcon,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return DeleteDialog<String>(
                          title: Text(context.l10n.dialog_delete_confirm),
                          header: _getDeleteHeader(context, key),
                          value: key,
                          successfully: (value) {
                            final oldEntry = vm.selected;
                            final List<String> chars = List.of(oldEntry.chars ?? []);
                            chars.remove(key);
                            final newEntry = oldEntry.copyWith(chars: chars);
                            context.dispatch(UpdateFontAction(newEntry));
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
      },
    );
  }

  String convertToEmoji(String input) {
    final String d = input.replaceAll('\\u', '');
    return '\\u{$d}';
  }

  String? _validateCharInput(BuildContext context, String input) {
    if (input.trim().isEmpty) {
      return context.l10n.error_card_empty;
    }

    if (!input.startsWith('\\u')) {
      return context.l10n.error_not_unicode_start;
    }

    if (input.length > 6) {
      return context.l10n.error_not_unicode;
    }
    return null;
  }

  List<TextSpan> _getDeleteHeader(BuildContext context, String key) {
    return [
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
    ];
  }
}
