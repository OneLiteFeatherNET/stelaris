import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/select_font_vm.dart';
import 'package:stelaris/feature/base/chips/action_chips.dart';
import 'package:stelaris/feature/base/chips/edit_action_chips.dart';
import 'package:stelaris/feature/dialogs/abort_add_dialog.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/font/chars/char_list_view.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/edit_mode.dart';
import 'package:stelaris/util/l10n_ext.dart';

const List<EditMode> editModes = EditMode.values;

class CharCard extends StatefulWidget {
  const CharCard({super.key});

  @override
  State<CharCard> createState() => _CharCardState();
}

class _CharCardState extends State<CharCard> {
  EditMode editMode = EditMode.edit;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedFontView>(
      vm: () => SelectedFontFactory<CharCard>(),
      onWillChange: (context, store, previousVm, newVm) {
        if ((previousVm.selected.chars.length) >
            (newVm.selected.chars.length)) {
          editMode = EditMode.edit;
        }
      },
      builder: (context, vm) {
        return Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              verticalSpacing25,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: _getActionWidget(vm, context),
                  ),
                  SegmentedButton<EditMode>(
                    segments: List.generate(
                      editModes.length,
                      (index) => ButtonSegment<EditMode>(
                        value: editModes[index],
                        label: Text(editModes[index].value),
                      ),
                    ),
                    selected: {editMode},
                    onSelectionChanged: (selected) {
                      setState(
                        () {
                          editMode = selected.first;

                          if (editMode == EditMode.edit) {
                            vm.clearDeleted();
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              verticalSpacing25,
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: (!vm.hasChars)
                    ? const EmptyDataWidget()
                    : CharListView(
                        fontModel: vm,
                        editMode: editMode,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getActionWidget(SelectedFontView view, BuildContext context) {
    return editMode == EditMode.edit
        ? ActionChips(
            addCallback: () => _addDialog(view, context),
            saveCallback: () {
              ApiService().fontAPI.update(view.selected);
            },
          )
        : EditActionChips(
            deleteConfirm: () => _showDeleteDialog(view, context));
  }

  List<TextSpan> _getDeleteHeader(BuildContext context, List<String> keys) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final spanTiles = List.generate(
      keys.length,
      (index) {
        return TextSpan(
          text: '${keys[index]}\n',
          style: redStyle,
        );
      },
    );
    spanTiles.insert(
      0,
      TextSpan(
        text: 'The deletion contains following entries:\n\n',
        style: textStyle,
      ),
    );
    return spanTiles;
  }

  void _showDeleteDialog(SelectedFontView view, BuildContext context) {
    if (view.selectedFields.isEmpty) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog<Set<String>>(
          title: Text(
            context.l10n.dialog_delete_confirm,
            textAlign: TextAlign.center,
          ),
          header: _getDeleteHeader(context, view.selectedFields.toList()),
          value: view.selectedFields,
          successfully: (value) {
            if (!view.hasChars) return false;
            final oldEntry = view.selected;
            final List<String> chars =
                List.of(view.selected.chars, growable: true);

            for (String element in view.selectedFields) {
              chars.remove(element);
            }

            view.clearDeleted();

            final newEntry = oldEntry.copyWith(chars: chars);
            context.dispatch(UpdateFontAction(newEntry));
            return true;
          },
        );
      },
    );
  }

  void _addDialog(SelectedFontView view, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          valueUpdate: (value) {
            final String charValue = value;
            if (view.hasChar(charValue)) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AbortAddDialog(
                    title: context.l10n.dialog_abort_chars_add,
                    content: '${context.l10n.dialog_abort_chars_text} $value',
                  );
                },
              );
              return;
            }
            final oldEntry = view.selected;
            final List<String> chars = List.of(oldEntry.chars);
            chars.add(value);
            final newEntry = oldEntry.copyWith(chars: chars);
            context.dispatch(UpdateFontAction(newEntry));
            Navigator.pop(context);
          },
          formFieldValidator: (value) => _validateCharInput(context, value),
          title: context.l10n.button_add_new_line,
          formKey: GlobalKey<FormState>(),
        );
      },
    );
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
}
