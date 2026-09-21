import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/base/mixins/infinite_scroll_mixin.dart';
import 'package:stelaris/feature/model/command_bar.dart';
import 'package:stelaris/feature/model/filter_option.dart';
import 'package:stelaris/feature/model/model_filter.dart';
import 'package:stelaris/feature/model/model_grid_card.dart';
import 'package:stelaris/feature/model/model_sort_option.dart';
import 'package:stelaris/feature/model/model_sorter.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/typedefs.dart';

/// Decides whether [model] matches the free-text [query] from the
/// [CommandBar]. [query] is already lowercased by [ModelPage], so
/// implementations only need to lowercase the field(s) they compare it to.
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

/// Returns [model]'s namespaced-key part, used to build the namespaced key
/// shown in the info dialog opened from a model card's action menu.
typedef ModelKeySelector<E extends DataModel> = String Function(E model);

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
  final ModelKeySelector<E> keySelector;

  /// The current project's key — used to build the namespaced key shown in
  /// the info dialog opened from a model card's action menu.
  final String projectKey;

  /// Whether a given model instance has related/embedded data worth
  /// offering an "include relationships" choice for. Omitted by pages
  /// whose model type never has any (e.g. attributes, notifications).
  final HasRelationshipData<E>? hasRelationshipData;

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
    required this.keySelector,
    required this.projectKey,
    required this.onRefresh,
    this.hasRelationshipData,
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
  static const double _commandBarMaxWidth = 640;
  // Single source of truth for the page's horizontal margin — applied once
  // below instead of separately on the command bar and the grid, so the
  // two can't drift out of alignment with each other.
  static const double _horizontalPagePadding = 16;
  static const double _gridMaxCardExtent = 320;
  static const double _gridCardHeight = 148;
  static const double _gridSpacing = 12;
  static const int _gridMaxColumns = 4;

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
    final filtered = filterModels(
      models: widget.models,
      // Lowercased once here rather than inside matchesSearch per model.
      query: listState.searchQuery.toLowerCase(),
      activeFilters: listState.activeFilters,
      matchesSearch: widget.matchesSearch,
      matchesFilter: widget.matchesFilter,
    );

    return sortModels(
      models: filtered,
      sortField: listState.sortField,
      sortDirection: listState.sortDirection,
      nameSelector: widget.nameSelector,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // The page's only horizontal inset — the grid below relies on this
      // same padding rather than adding its own, so it can't line up
      // differently than the command bar above it.
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Breathing room under the AppBar instead of butting straight up
          // against it.
          const SizedBox(height: _horizontalPagePadding),
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
      ),
    );
  }

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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Same column-width target as before (_gridMaxCardExtent), but
        // capped at _gridMaxColumns so wide screens don't stretch the grid
        // to 5+ columns.
        final rawColumns =
            (constraints.maxWidth + _gridSpacing) /
            (_gridMaxCardExtent + _gridSpacing);
        final columns = rawColumns.floor().clamp(1, _gridMaxColumns);

        return CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPadding(
              // Horizontal inset already comes from the page-level Padding
              // in build() — only vertical spacing is this sliver's own.
              padding: const EdgeInsets.symmetric(vertical: 4),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
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
      },
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
      nameSelector: widget.nameSelector,
      keySelector: widget.keySelector,
      projectKey: widget.projectKey,
      hasRelationshipData: widget.hasRelationshipData,
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
