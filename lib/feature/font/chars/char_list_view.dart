import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/font/font_string_dto.dart';
import 'package:stelaris/api/model/font_model.dart';
import 'package:stelaris/api/state/actions/font/font_string_actions.dart';
import 'package:stelaris/api/state/factory/font/selected_font_char_state.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/font/chars/actions/font_char_entry_actions.dart';
import 'package:stelaris/util/functions.dart';

class CharListView extends StatefulWidget {
  const CharListView({
    required this.fontModel,
    super.key,
  });

  final SelectedFontCharView fontModel;

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
        itemCount: widget.fontModel.chars.length,
        cacheExtent: 100,
        itemBuilder: (context, index) {
          final key = widget.fontModel.chars[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Card(
              elevation: 1,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: Text(key.line),
                trailing: FontCharEntryActions(
                  onEdit: () => _handleEdit(index, key.line),
                  onDelete: () => _handleDelete(widget.fontModel.selected.id!, key),
                ),
              ),
            ),
          );
        },
      )
    );
  }

  void _handleDelete(String id, FontStringDTO key) {
    showDialog(context: context, builder: (context) {
      return DeleteDialog<FontStringDTO>(title: const Text('Delete char'),
        header: createDeleteText(key.line, context),
        value: key,
        successfully: (value) {
          Navigator.of(context).pop(true);
          context.dispatch(FontStringDelete(id, key));
          return false;
        },
      );
    });
  }

  /// The method handles the edition of an existing char from the given [FontModel].
  /// For the edition, it opens a dialog with the current char value and allows the user to update it.
  /// If the user updates the char, the method updates the [FontModel] with the new value.
  void _handleEdit(int index, String originalData) {
    showDialog(
      context: context,
      builder: (context) {
        return EntryUpdateDialog(
          title: 'Edit char',
          formKey: GlobalKey<FormState>(),
          data: originalData,
          valueUpdate: (value) {
            /*final String updatedValue = value;
            if (updatedValue.isEmpty || updatedValue == originalData) return;
            final List<String> modelChars = List.of(widget.fontModel.chars, growable: true);
            modelChars.removeAt(index);
            modelChars.insert(index, updatedValue);
            final FontModel updatedModel =
                widget.fontModel.selected.copyWith(chars: modelChars);
            context.dispatch(UpdateFontAction(updatedModel));*/
            Navigator.of(context).pop(true);
          },
        );
      },
    );
  }
}
