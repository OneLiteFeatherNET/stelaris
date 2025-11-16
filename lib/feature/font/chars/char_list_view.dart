import 'dart:async';
import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/font/font_string_dto.dart';
import 'package:stelaris/api/model/font_model.dart';
import 'package:stelaris/api/state/actions/font/font_string_actions.dart';
import 'package:stelaris/api/state/factory/font/selected_font_char_state.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/font/chars/char_list_item.dart';
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant CharListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
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
          cacheExtent: 100,
          itemBuilder: (context, index) {
            final key = widget.fontModel.chars[index];
            return CharListItem(
              key: ValueKey(key.id),
              fontString: key,
              onEdit: () => _handleEdit(index, key.line),
              onDelete: () =>
                  _handleDelete(widget.fontModel.selected.id!, key),
            );
          },
        ));
  }

  void _handleDelete(String id, FontStringDTO key) {
    showDialog(
        context: context,
        builder: (context) {
          return DeleteDialog<FontStringDTO>(
            title: const Text('Delete char'),
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

  void _onScroll() {
    if (!_scrollController.hasClients || widget.fontModel.isLoadingMore) return;
    final chars = widget.fontModel.selected.chars;
    if (chars.currentPage >= chars.totalPages) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final triggerFetchMoreSize = maxScroll * 0.7;

    if (currentScroll >= triggerFetchMoreSize) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        context.dispatch(FontCharFetchAction());
      });
    }
  }
}
