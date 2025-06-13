import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/font_model.dart';
import 'package:stelaris/api/state/actions/font_actions.dart';
import 'package:stelaris/api/state/factory/font/select_font_vm.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/font/chars/char_delete_checkbox.dart';
import 'package:stelaris/util/edit_mode.dart';

class CharListView extends StatefulWidget {
  const CharListView({
    required this.fontModel,
    required this.editMode,
    super.key,
  });

  final SelectedFontView fontModel;
  final EditMode editMode;

  @override
  State<CharListView> createState() => _CharListViewState();
}

class _CharListViewState extends State<CharListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.fontModel.chars.length,
        itemBuilder: (context, index) {
          final key = widget.fontModel.chars[index];
          return ListTile(
            title: Text(key),
            trailing: _getTrailingWidget(context, index),
          );
        },
      ),
    );
  }

  /// The method returns the trailing [Widget] for the [ListTile] which displays the string value of the char.
  /// A trailing widget can have two different states: deleting or editing.
  /// If the [editMode] is deleting, the method returns a [CharDeleteCheckbox] widget.
  /// If the [editMode] is editing, the method returns an [IconButton] widget with an edit icon.
  Widget _getTrailingWidget(BuildContext context, int index) {
    final charEntry = widget.fontModel.chars[index];
    if (widget.editMode == EditMode.deleting) {
      return CharDeleteCheckbox(
        selectedFontView: widget.fontModel,
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
            final String updatedValue = value;
            if (updatedValue.isEmpty || updatedValue == originalData) return;
            final List<String> modelChars = List.of(widget.fontModel.chars, growable: true);
            modelChars.removeAt(index);
            modelChars.insert(index, updatedValue);
            final FontModel updatedModel =
                widget.fontModel.selected.copyWith(chars: modelChars);
            context.dispatch(UpdateFontAction(updatedModel));
            Navigator.of(context).pop(true);
          },
        );
      },
    );
  }
}
