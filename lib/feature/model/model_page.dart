import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/base/mixins/infinite_scroll_mixin.dart';
import 'package:stelaris/feature/model/command_bar.dart';
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

/// The search/filter/sort choices applied to a [ModelPage]'s list. Held in
/// a [ValueNotifier] rather than [State] fields so that changing it doesn't
/// require rebuilding the whole page — see [_ModelPageState].
class _ModelListState {
  const _ModelListState({
    this.searchQuery = '',
    this.activeFilters = const {},
    // Matches CommandBar's own initial default, so the first render is
    // already sorted the same way the sort menu shows as selected.
    this.sortField = SortField.name,
    this.sortDirection = SortDirection.ascending,
  });

  final String searchQuery;
  final Set<FilterOption> activeFilters;
  final SortField sortField;
  final SortDirection sortDirection;

  _ModelListState copyWith({
    String? searchQuery,
    Set<FilterOption>? activeFilters,
    SortField? sortField,
    SortDirection? sortDirection,
  }) {
    return _ModelListState(
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}

/// A page-level widget combining a [CommandBar] with a responsive,
/// scrollable grid of data models, with optional infinite-scroll pagination
/// via [onLoadMore]/[hasMore]/[isLoadingMore].
///
/// Tapping a model does not swap an in-place detail panel: the caller
/// decides what happens via [onModelTap] (e.g. navigating to a dedicated
/// detail route).
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

  /// Manually re-fetches page 1 from the server and replaces the list,
  /// regardless of how many pages were already loaded via [onLoadMore] —
  /// the grid has no pull-to-refresh gesture of its own, so this is
  /// surfaced as a button in the [CommandBar] instead.
  final VoidCallback onRefresh;
  final bool isRefreshing;

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
    required this.onRefresh,
    this.isRefreshing = false,
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
  // Search/filter/sort live here, not in State fields updated via
  // setState(). That keeps changing them from re-running this State's
  // build() at all — only the ValueListenableBuilder around the grid
  // (below) does — so CommandBar, constructed directly in build(), is
  // never reconstructed just because the user typed or picked a filter.
  final ValueNotifier<_ModelListState> _listState = ValueNotifier(
    const _ModelListState(),
  );

  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _listState.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _listState.value = _listState.value.copyWith(searchQuery: query);
    });
  }

  void _handleFiltersChanged(Set<FilterOption> filters) {
    _listState.value = _listState.value.copyWith(activeFilters: filters);
  }

  void _handleSortChanged(SortField field, SortDirection direction) {
    _listState.value = _listState.value.copyWith(
      sortField: field,
      sortDirection: direction,
    );
  }

  @override
  bool canLoadMore() => widget.hasMore;

  @override
  bool isLoadingMore() => widget.isLoadingMore;

  @override
  void onLoadMore() => widget.onLoadMore?.call();

  List<E> _filteredModels(_ModelListState listState) {
    final filtered =
        listState.searchQuery.isEmpty && listState.activeFilters.isEmpty
        ? widget.models.toList()
        : widget.models.where((model) {
            final matchesQuery = listState.searchQuery.isEmpty ||
                widget.matchesSearch(model, listState.searchQuery);
            final matchesFilters = listState.activeFilters.isEmpty ||
                listState.activeFilters
                    .every((filter) => widget.matchesFilter(model, filter));
            return matchesQuery && matchesFilters;
          }).toList();

    filtered.sort((a, b) => _compareModels(a, b, listState));
    return filtered;
  }

  int _compareModels(E a, E b, _ModelListState listState) {
    final directionMultiplier =
        listState.sortDirection == SortDirection.descending ? -1 : 1;

    switch (listState.sortField) {
      case SortField.name:
        final comparison = widget
            .nameSelector(a)
            .toLowerCase()
            .compareTo(widget.nameSelector(b).toLowerCase());
        return comparison * directionMultiplier;
      case SortField.createdAt:
        final aDate = a.creationDate;
        final bDate = b.creationDate;
        // Undated models always sort last, regardless of direction —
        // negating the comparison for "descending" must not also flip
        // which end of the list they land on.
        return switch ((aDate, bDate)) {
          (null, null) => 0,
          (null, _) => 1,
          (_, null) => -1,
          (final aDate?, final bDate?) =>
            aDate.compareTo(bDate) * directionMultiplier,
        };
    }
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
            child: CommandBar(
              onAdd: widget.onAdd,
              onSearchChanged: _handleSearchChanged,
              filterOptions: widget.filterOptions,
              onFiltersChanged: _handleFiltersChanged,
              onSortChanged: _handleSortChanged,
              onRefresh: widget.onRefresh,
              isRefreshing: widget.isRefreshing,
            ),
          ),
        ),
        verticalSpacing10,
        Expanded(
          child: ValueListenableBuilder<_ModelListState>(
            valueListenable: _listState,
            builder: (context, listState, _) => _buildGridView(listState),
          ),
        ),
      ],
    );
  }

  static const double _gridMaxCardExtent = 320;
  static const double _gridCardHeight = 132;
  static const double _gridSpacing = 12;

  Widget _buildGridView(_ModelListState listState) {
    final models = _filteredModels(listState);

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
    // No explicit RepaintBoundary here — SliverChildBuilderDelegate already
    // wraps each built child in one (addRepaintBoundaries defaults to true),
    // so adding another would just double the compositing layer per card.
    return ModelGridCard<E>(
      key: model.id != null ? ValueKey(model.id) : ObjectKey(model),
      mapToDeleteDialog: widget.mapToDeleteDialog,
      mapToDeleteSuccessfully: widget.mapToDeleteSuccessfully,
      mapToDataModelItem: widget.mapToDataModelItem,
      rawModel: model,
      onTap: () => widget.onModelTap(model),
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
