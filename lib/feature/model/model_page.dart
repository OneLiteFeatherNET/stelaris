import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/search_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/model_search_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/base/mixins/infinite_scroll_mixin.dart';
import 'package:stelaris/feature/model/filter_option.dart';
import 'package:stelaris/feature/model/model_filter.dart';
import 'package:stelaris/feature/model/model_grid_card.dart';
import 'package:stelaris/feature/model/model_sort_option.dart';
import 'package:stelaris/feature/model/model_sorter.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/typedefs.dart';

/// Decides whether [model] matches the free-text [query] from the
/// AppBar search. [query] is already lowercased by [ModelPage], so
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

/// A page-level widget combining a [PageHeader] with a responsive,
/// scrollable grid of data models, with optional infinite-scroll pagination
/// via [onLoadMore]/[hasMore]/[isLoadingMore].
///
/// Tapping a model does not swap an in-place detail panel: the caller
/// decides what happens via [onModelTap] (e.g. navigating to a dedicated
/// detail route).
class ModelPage<E extends DataModel> extends StatefulWidget {
  /// The section this list belongs to — titles the header.
  final NavigationEntry entry;
  final List<E> models;
  final MapToDataModelItem<E> mapToDataModelItem;

  /// The type-specific wording of the delete dialog opened from a card.
  final String deleteTitle;
  final String? deleteWarning;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final VoidCallback onAdd;
  final ValueChanged<E> onModelTap;
  final ModelFilterMatcher<E> matchesFilter;
  final List<FilterOption> filterOptions;
  final ModelNameSelector<E> nameSelector;
  final ModelKeySelector<E> keySelector;

  /// The current project's key — used to build the namespaced key shown in
  /// the info dialog opened from a model card's action menu.
  final String projectKey;

  /// Manually re-fetches page 1 from the server and replaces the list,
  /// regardless of how many pages were already loaded via [onLoadMore] —
  /// the grid has no pull-to-refresh gesture of its own, so this is
  /// surfaced as an action in the [PageHeader] instead.
  final VoidCallback onRefresh;
  final bool isRefreshing;

  /// Pagination hooks
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  const ModelPage({
    required this.entry,
    required this.models,
    required this.mapToDataModelItem,
    required this.deleteTitle,
    required this.mapToDeleteSuccessfully,
    required this.onAdd,
    required this.onModelTap,
    required this.matchesFilter,
    required this.nameSelector,
    required this.keySelector,
    required this.projectKey,
    required this.onRefresh,
    this.deleteWarning,
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
  // Single source of truth for the page's horizontal margin — applied once
  // below instead of separately on the header and the grid, so the
  // two can't drift out of alignment with each other.
  static const double _horizontalPagePadding = 16;
  static const double _gridMaxCardExtent = 320;
  static const double _gridCardHeight = 148;
  static const double _gridSpacing = 12;
  static const int _gridMaxColumns = 4;

  @override
  void initState() {
    super.initState();
    // After the first frame: dispatching during initState would notify the
    // AppBar search mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Also tells the search which section it belongs to: a search typed
      // in another section is dropped here.
      context.dispatch(
        RegisterSearchFiltersAction(widget.entry, widget.filterOptions),
      );
    });
  }

  @override
  bool canLoadMore() => widget.hasMore;

  @override
  bool isLoadingMore() => widget.isLoadingMore;

  @override
  void onLoadMore() => widget.onLoadMore?.call();

  List<E> _filteredModels(ModelSearchState search) {
    final filtered = filterModels(
      models: widget.models,
      query: search.query.toLowerCase(),
      activeFilters: search.activeFilters,
      matchesSearch: (model, query) =>
          widget.nameSelector(model).toLowerCase().contains(query) ||
          widget.keySelector(model).toLowerCase().contains(query),
      matchesFilter: widget.matchesFilter,
    );

    return sortModels(
      models: filtered,
      sortField: search.sortField,
      sortDirection: search.sortDirection,
      nameSelector: widget.nameSelector,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      // The page's only horizontal inset — the grid below relies on this
      // same padding rather than adding its own, so it can't line up
      // differently than the header above it.
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          PageHeader(
            title: '${widget.entry.display} (${widget.models.length})',
            actions: [
              PageHeaderAction(
                icon: const Icon(Icons.refresh),
                label: l10n.command_bar_refresh_tooltip,
                loading: widget.isRefreshing,
                onPressed: widget.onRefresh,
              ),
              PageHeaderAction(
                icon: addModelIcon,
                label: l10n.button_add,
                primary: true,
                onPressed: widget.onAdd,
              ),
            ],
          ),
          verticalSpacing10,
          Expanded(
            // Only the grid listens to the search — typing in the AppBar
            // doesn't rebuild the header above.
            child: StoreConnector<AppState, ModelSearchState>(
              converter: (store) => store.state.modelSearch,
              builder: (context, search) => _buildGridView(search),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(ModelSearchState search) {
    final models = _filteredModels(search);

    if (models.isEmpty && widget.models.isNotEmpty) {
      final l10n = context.l10n;
      return EmptyDataWidget.full(
        header: l10n.search_no_results,
        subHeader: l10n.search_no_results_hint,
        icon: Icons.search_off,
        action: TextButton(
          onPressed: () => context.dispatch(ClearSearchAction()),
          child: Text(l10n.search_reset),
        ),
      );
    }

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
      deleteTitle: widget.deleteTitle,
      deleteWarning: widget.deleteWarning,
      mapToDeleteSuccessfully: widget.mapToDeleteSuccessfully,
      mapToDataModelItem: widget.mapToDataModelItem,
      rawModel: model,
      nameSelector: widget.nameSelector,
      keySelector: widget.keySelector,
      projectKey: widget.projectKey,
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
