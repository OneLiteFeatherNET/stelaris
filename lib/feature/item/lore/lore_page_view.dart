import 'package:stelaris/feature/base/mixins/infinite_scroll_mixin.dart';
import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item/item_lore_actions.dart';
import 'package:stelaris/api/state/factory/item/item_lore_view_state.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/item/lore/lore_line_card.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/l10n_ext.dart';

class LorePageView extends StatefulWidget {
  const LorePageView({required this.view, super.key});

  final ItemLoreView view;

  @override
  State<LorePageView> createState() => _LorePageViewState();
}

class _LorePageViewState extends State<LorePageView>
    with InfiniteScrollMixin<LorePageView> {
  @override
  bool canLoadMore() {
    final lore = widget.view.selected.lore;
    return lore.hasNextPage;
  }

  @override
  bool isLoadingMore() => widget.view.isLoadingMore;

  @override
  void onLoadMore() {
    context.dispatch(ItemLoreLoadNextPageAction());
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.view.items;
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: ReorderableListView.builder(
        scrollController: scrollController,
        // Room for the scrollbar, so it doesn't cover the actions.
        padding: const EdgeInsets.only(right: 16),
        // The cards bring their own drag handle.
        buildDefaultDragHandles: false,
        proxyDecorator: (child, index, animation) => AnimatedBuilder(
          animation: animation,
          builder: (context, _) => _buildLine(
            items[index],
            index,
            lift: Curves.easeOut.transform(animation.value),
          ),
        ),
        itemBuilder: (context, index) =>
            _buildLine(items[index], index, key: Key(items[index].id!)),
        itemCount: items.length,
        onReorderItem: (oldIndex, newIndex) {
          if (oldIndex == newIndex) return;

          if (newIndex > items.length - 1) {
            newIndex = items.length - 1;
          }

          context.dispatch(
            ItemLoreReorderAction(
              oldIndex: oldIndex,
              newIndex: newIndex,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLine(
    ItemLoreDto dto,
    int index, {
    Key? key,
    double lift = 0,
  }) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 8),
      child: LoreLineCard(
        dto: dto,
        index: index,
        lift: lift,
        onEdit: () => _showDialog(dto),
        onDelete: () => _showDeleteDialog(dto),
      ),
    );
  }

  void _showDeleteDialog(ItemLoreDto dto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog<ItemLoreDto>(
          title: context.l10n.dialog_item_lore_delete_title,
          header: [TextSpan(text: context.l10n.dialog_item_lore_delete_header)],
          value: dto,
          successfully: (value) {
            context.dispatch(ItemLoreDeleteAction(value));
            return true;
          },
        );
      },
    );
  }

  void _showDialog(ItemLoreDto dto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          title: context.l10n.dialog_item_lore_edit_title,
          formKey: GlobalKey<FormState>(),
          valueUpdate: (value) {
            final updatedDto = dto.copyWith(text: value);
            context.dispatch(ItemLoreUpdateAction(updatedDto));
            Navigator.pop(context, false);
          },
          formFieldValidator: (value) {
            final String input = value as String;
            return checkIfEmptyAndReturnErrorString(input, context);
          },
          data: dto.text,
        );
      },
    );
  }
}
