import 'package:flutter/foundation.dart' show listEquals;
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/base/mixins/infinite_scroll_mixin.dart';
import 'package:stelaris/feature/model/filter_option.dart';
import 'package:stelaris/feature/model/model_grid_card.dart';
import 'package:stelaris/feature/model/model_sort_option.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/typedefs.dart';

/// Decides whether [model] matches the free-text [query] from the [CommandBar].
typedef ModelSearchMatcher<E extends DataModel> = bool Function(
  E model,
  String query,
);

/// Decides whether [model] matches an active [FilterOption].
typedef ModelFilterMatcher<E extends DataModel> = bool Function(
  E model,
  FilterOption filter,
);

/// Returns [model]'s display name, used for [SortField.name] sorting.
typedef ModelNameSelector<E extends DataModel> = String Function(E model);

/// A page-level widget combining a [CommandBar] with a responsive,
/// scrollable grid of data models, with optional infinite-scroll pagination
/// via [onLoadMore]/[hasMore]/[isLoadingMore].
///
/// Unlike [PaginatedModelList], tapping a model does not swap an in-place
/// detail panel: the caller decides what happens via [onModelTap] (e.g.
/// navigating to a dedicated detail route).
class ModelPage<E extends DataModel> extends StatefulWidget {
  final List<E> models;
  final MapToDataModelItem<E> mapToDataModelItem;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final VoidCallback onAdd;
  final ValueChanged<E> onModelTap;
  final ModelSearchMatcher<E> matchesSearch;
  final ModelFilterMatcher<E> matchesFilter;
  final List<FilterOption> filterOptions;
  final ModelNameSelector<E> nameSelector;

  /// Pagination hooks
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  const ModelPage({
    required this.models,
    required this.mapToDataModelItem,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.onAdd,
    required this.onModelTap,
    required this.matchesSearch,
    required this.matchesFilter,
    required this.nameSelector,
    this.filterOptions = const [],
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    super.key,
  });

  @override
  State<ModelPage<E>> createState() => _ModelPageState<E>();
}

class _ModelPageState<E extends DataModel> extends State<ModelPage<E>>
    with InfiniteScrollMixin<ModelPage<E>> {
  String _searchQuery = '';
  Set<FilterOption> _activeFilters = {};

  // Matches CommandBar's own initial default, so the first render is
  // already sorted the same way the sort menu shows as selected.
  SortField _sortField = SortField.name;
  SortDirection _sortDirection = SortDirection.ascending;

  // CommandBar owns its own search/filter/sort UI state internally and
  // doesn't take any of the fields above as input, so it never actually
  // needs to change in response to them — building it once and reusing the
  // same instance lets Flutter skip rebuilding it on every keystroke
  // instead of reconstructing (and re-rendering) it on every setState here.
  late Widget _commandBar = _buildCommandBar();

  @override
  void didUpdateWidget(covariant ModelPage<E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onAdd != widget.onAdd ||
        !listEquals(oldWidget.filterOptions, widget.filterOptions)) {
      _commandBar = _buildCommandBar();
    }
  }

  Widget _buildCommandBar() {
    return CommandBar(
      onAdd: widget.onAdd,
      onSearchChanged: _handleSearchChanged,
      filterOptions: widget.filterOptions,
      onFiltersChanged: _handleFiltersChanged,
      onSortChanged: _handleSortChanged,
    );
  }

  void _handleSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

  void _handleFiltersChanged(Set<FilterOption> filters) {
    setState(() => _activeFilters = filters);
  }

  void _handleSortChanged(SortField field, SortDirection direction) {
    setState(() {
      _sortField = field;
      _sortDirection = direction;
    });
  }

  @override
  bool canLoadMore() => widget.hasMore;

  @override
  bool isLoadingMore() => widget.isLoadingMore;

  @override
  void onLoadMore() => widget.onLoadMore?.call();

  List<E> get _filteredModels {
    final filtered = _searchQuery.isEmpty && _activeFilters.isEmpty
        ? widget.models.toList()
        : widget.models.where((model) {
            final matchesQuery = _searchQuery.isEmpty ||
                widget.matchesSearch(model, _searchQuery);
            final matchesFilters = _activeFilters.isEmpty ||
                _activeFilters
                    .every((filter) => widget.matchesFilter(model, filter));
            return matchesQuery && matchesFilters;
          }).toList();

    filtered.sort(_compareModels);
    return filtered;
  }

  int _compareModels(E a, E b) {
    final int comparison;
    switch (_sortField) {
      case SortField.name:
        comparison = widget
            .nameSelector(a)
            .toLowerCase()
            .compareTo(widget.nameSelector(b).toLowerCase());
      case SortField.createdAt:
        final aDate = a.creationDate;
        final bDate = b.creationDate;
        // Undated models sort after dated ones (subject to the direction
        // flip below, same as any other comparison here).
        comparison = switch ((aDate, bDate)) {
          (null, null) => 0,
          (null, _) => 1,
          (_, null) => -1,
          (final aDate?, final bDate?) => aDate.compareTo(bDate),
        };
    }
    return _sortDirection == SortDirection.descending
        ? -comparison
        : comparison;
  }

  static const double _commandBarMaxWidth = 640;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _commandBarMaxWidth),
            child: _commandBar,
          ),
        ),
        verticalSpacing10,
        Expanded(child: _buildGridView()),
      ],
    );
  }

  static const double _gridMaxCardExtent = 320;
  static const double _gridCardHeight = 132;
  static const double _gridSpacing = 12;

  Widget _buildGridView() {
    final models = _filteredModels;

    if (models.isEmpty) {
      // Reuse the same empty-state copy the other (unmigrated) pages
      // already use for their "nothing to show" case, instead of
      // inventing new strings just for the grid.
      return EmptyDataWidget.standard(
        header: context.l10n.empty_data_header,
        subHeader: context.l10n.empty_data_subHeader,
      );
    }

    final hasFooter =
        widget.onLoadMore != null && (widget.isLoadingMore || widget.hasMore);

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(4),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: _gridMaxCardExtent,
              mainAxisExtent: _gridCardHeight,
              crossAxisSpacing: _gridSpacing,
              mainAxisSpacing: _gridSpacing,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildGridItem(context, models[index]),
              childCount: models.length,
            ),
          ),
        ),
        if (hasFooter) SliverToBoxAdapter(child: _buildFooter()),
      ],
    );
  }

  Widget _buildGridItem(BuildContext context, E model) {
    return RepaintBoundary(
      key: model.id != null ? ValueKey(model.id) : ObjectKey(model),
      child: ModelGridCard<E>(
        mapToDeleteDialog: widget.mapToDeleteDialog,
        mapToDeleteSuccessfully: widget.mapToDeleteSuccessfully,
        mapToDataModelItem: widget.mapToDataModelItem,
        rawModel: model,
        onTap: () => widget.onModelTap(model),
      ),
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
