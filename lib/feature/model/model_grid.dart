import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/mixins/infinite_scroll_mixin.dart';

/// The responsive grid of the model list pages, for any kind of [items]:
/// as many columns as cards of at most [maxCardExtent] fit, capped at
/// [maxColumns], each card [cardHeight] high. Scrolling near the end calls
/// [onLoadMore] while [hasMore], and a footer shows while [isLoadingMore].
///
/// The grid has no empty state; the page decides what to show without items.
class ModelGrid<T> extends StatefulWidget {
  const ModelGrid({
    required this.items,
    required this.itemBuilder,
    this.cardHeight = 148,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    super.key,
  });

  /// The widest a card gets before another column fits.
  static const double maxCardExtent = 320;

  /// The space between two cards, across and down.
  static const double spacing = 12;

  /// Wide screens don't stretch the grid to 5+ columns.
  static const int maxColumns = 4;

  final List<T> items;

  /// Builds the card of an item; give it a key from the item, so a card
  /// keeps its state when items move.
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double cardHeight;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  /// The number of columns for a grid [width] wide.
  static int columnsFor(double width) =>
      ((width + spacing) / (maxCardExtent + spacing)).floor().clamp(
        1,
        maxColumns,
      );

  @override
  State<ModelGrid<T>> createState() => _ModelGridState<T>();
}

class _ModelGridState<T> extends State<ModelGrid<T>>
    with InfiniteScrollMixin<ModelGrid<T>> {
  @override
  bool canLoadMore() => widget.hasMore;

  @override
  bool isLoadingMore() => widget.isLoadingMore;

  @override
  void onLoadMore() => widget.onLoadMore?.call();

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final hasFooter =
        widget.onLoadMore != null && (widget.isLoadingMore || widget.hasMore);

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPadding(
              // The page gives the horizontal inset, so the grid lines up
              // with the header above it.
              padding: const EdgeInsets.symmetric(vertical: 4),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ModelGrid.columnsFor(constraints.maxWidth),
                  mainAxisExtent: widget.cardHeight,
                  crossAxisSpacing: ModelGrid.spacing,
                  mainAxisSpacing: ModelGrid.spacing,
                ),
                // No explicit RepaintBoundary: SliverChildBuilderDelegate
                // already wraps each built child in one.
                delegate: SliverChildBuilderDelegate(
                  (context, index) => widget.itemBuilder(context, items[index]),
                  childCount: items.length,
                ),
              ),
            ),
            if (hasFooter) SliverToBoxAdapter(child: _buildFooter()),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: widget.isLoadingMore
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
