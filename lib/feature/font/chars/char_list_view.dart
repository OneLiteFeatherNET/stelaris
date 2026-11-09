import 'package:async_redux/async_redux.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/font/font_string_actions.dart';
import 'package:stelaris/api/state/factory/font/selected_font_char_state.dart';
import 'package:stelaris/feature/base/mixins/infinite_scroll_mixin.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/font/chars/char_list_item.dart';
import 'package:stelaris/feature/font/chars/dialog/font_char_dialog.dart';
import 'package:stelaris/util/font_part.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/l10n_ext.dart';

class CharListView extends StatefulWidget {
  const CharListView({required this.fontModel, super.key});

  final SelectedFontCharView fontModel;

  @override
  State<CharListView> createState() => _CharListViewState();
}

class _CharListViewState extends State<CharListView>
    with InfiniteScrollMixin<CharListView> {
  @override
  Widget build(BuildContext context) {
    final expectedLength = widget.fontModel.expectedLineLength;
    final cellWidth = codePointCellWidth(context);
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: ListView.builder(
        controller: scrollController,
        itemCount: widget.fontModel.chars.length,
        scrollCacheExtent: const ScrollCacheExtent.pixels(100),
        itemBuilder: (context, index) {
          final key = widget.fontModel.chars[index];
          return CharListItem(
            key: ValueKey(key.id),
            fontString: key,
            index: index,
            expectedLength: expectedLength,
            codePointWidth: cellWidth,
            onEdit: () => _handleEdit(key),
            onDelete: () => _handleDelete(widget.fontModel.selected.id!, key),
          );
        },
      ),
    );
  }

  void _handleDelete(String id, FontStringDTO key) {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteDialog<FontStringDTO>(
          title: context.l10n.dialog_font_char_delete,
          header: createDeleteText(formatCodePoints(key.line), context),
          value: key,
          successfully: (value) {
            Navigator.of(context).pop(true);
            context.dispatch(FontStringDelete(id, key));
            return false;
          },
        );
      },
    );
  }

  /// Opens the dialog to edit the line [dto].
  void _handleEdit(FontStringDTO dto) {
    showDialog(
      context: context,
      builder: (context) => FontCharDialog(fontString: dto),
    );
  }

  @override
  bool canLoadMore() {
    final chars = widget.fontModel.selected.chars;
    return chars.currentPage < chars.totalPages;
  }

  @override
  bool isLoadingMore() => widget.fontModel.isLoadingMore;

  @override
  void onLoadMore() {
    context.dispatch(FontCharFetchAction());
  }
}
