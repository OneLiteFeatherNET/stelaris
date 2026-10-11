import 'package:stelaris/feature/base/mixins/infinite_scroll_mixin.dart';
import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item/item_lore_actions.dart';
import 'package:stelaris/api/state/factory/item/item_lore_view_state.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/component/component_dialog.dart';
import 'package:stelaris/feature/item/lore/lore_line_card.dart';
import 'package:stelaris/feature/item/lore/lore_preview.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/l10n_ext.dart';

class LorePageView extends StatefulWidget {
  const LorePageView({
    required this.view,
    this.showPreview = false,
    super.key,
  });

  final ItemLoreView view;

  /// Whether the tooltip preview sits next to the lines. The caller decides
  /// whether there is room for it.
  final bool showPreview;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        // The list keeps its place in the row whether the preview shows or
        // not, so toggling the preview doesn't build the list from scratch.
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildList()),
            // Slides and fades in from the right edge, the list gives way.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                // Top, the transition fills the height and would center it.
                alignment: AlignmentDirectional.topStart,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: widget.showPreview
                  ? Padding(
                      key: const ValueKey('lore_preview_slot'),
                      padding: const EdgeInsets.only(left: 16),
                      child: SizedBox(
                        width: (constraints.maxWidth * 0.35).clamp(280, 420),
                        child: LorePreview(item: widget.view.selected),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList() {
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
        return ComponentDialog(
          title: context.l10n.dialog_item_lore_edit_title,
          actionLabel: context.l10n.button_save,
          componentContext: ComponentContext.lore,
          initialValue: dto.text,
          onSave: (value) {
            final updatedDto = dto.copyWith(text: value);
            context.dispatch(ItemLoreUpdateAction(updatedDto));
            Navigator.pop(context, false);
          },
        );
      },
    );
  }
}
