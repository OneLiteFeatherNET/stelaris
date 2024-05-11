import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/state/actions/font_actions.dart';
import 'package:stelaris_ui/api/state/factory/font/select_font_vm.dart';
import 'package:stelaris_ui/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris_ui/feature/font/chars/char_delete_checkbox.dart';
import 'package:stelaris_ui/util/edit_mode.dart';

class CharListView extends StatelessWidget {
  const CharListView({
    required this.fontModel,
    required this.editMode,
    super.key,
  });

  final SelectedFontView fontModel;
  final EditMode editMode;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: fontModel.chars.length,
      itemBuilder: (context, index) {
        final key = fontModel.chars[index];
        return ListTile(
          title: Text(key),
          trailing: _getTrailingWidget(context, index),
        );
      },
    );
  }

  /// The method returns the trailing [Widget] for the [ListTile] which displays the string value of the char.
  /// A trailing widget can have two different states: deleting or editing.
  /// If the [editMode] is deleting, the method returns a [CharDeleteCheckbox] widget.
  /// If the [editMode] is editing, the method returns an [IconButton] widget with an edit icon.
  Widget _getTrailingWidget(BuildContext context, int index) {
    final charEntry = fontModel.chars[index];
    if (editMode == EditMode.deleting) {
      return CharDeleteCheckbox(
        selectedFontView: fontModel,
        charIndex: charEntry,
      );
    } else {
      return IconButton(
        onPressed: () => _handleEdit(index, charEntry, context),
        icon: const Icon(Icons.edit),
      );
    }
  }

  /// The method handles the edition of an existing char from the given [FontModel].
  /// For the edition, it opens a dialog with the current char value and allows the user to update it.
  /// If the user updates the char, the method updates the [FontModel] with the new value.
  void _handleEdit(int index, String originalData, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return EntryUpdateDialog(
          title: 'Edit char',
          formKey: GlobalKey<FormState>(),
          data: originalData,
          valueUpdate: (value) {
            final String updatedValue = value!;
            if (updatedValue.isEmpty || updatedValue == originalData) return;
            final List<String> modelChars = List.of(fontModel.chars, growable: true);
            modelChars.removeAt(index);
            modelChars.insert(index, updatedValue);
            final FontModel updatedModel =
                fontModel.selected.copyWith(chars: modelChars);
            context.dispatch(UpdateFontAction(updatedModel));
            Navigator.of(context).pop(true);
          },
        );
      },
    );
  }
}
