import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/font/font_string_actions.dart';
import 'package:stelaris/api/state/factory/font/selected_font_char_state.dart';
import 'package:stelaris/feature/base/mixins/infinite_scroll_mixin.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/font/chars/char_list_item.dart';
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
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: ListView.builder(
        controller: scrollController,
        itemCount: widget.fontModel.chars.length,
        cacheExtent: 100,
        itemBuilder: (context, index) {
          final key = widget.fontModel.chars[index];
          return CharListItem(
            key: ValueKey(key.id),
            fontString: key,
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
          title: Text(context.l10n.dialog_font_char_delete),
          header: createDeleteText(key.line, context),
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

  /// The method handles the edition of an existing char from the given [FontModel].
  /// For the edition, it opens a dialog with the current char value and allows the user to update it.
  /// If the user updates the char, the method updates the [FontModel] with the new value.
  void _handleEdit(FontStringDTO dto) {
    showDialog(
      context: context,
      builder: (context) {
        return EntryUpdateDialog(
          title: context.l10n.dialog_font_char_edit,
          formKey: GlobalKey<FormState>(),
          data: dto.line,
          valueUpdate: (value) {
            final String updatedValue = value;
            if (updatedValue.isEmpty || updatedValue == dto.line) return;
            context.dispatch(
              FontStringEditAction(dto.copyWith(line: updatedValue)),
            );
            Navigator.of(context).pop(true);
          },
        );
      },
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
