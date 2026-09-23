import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/model_search_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/filter_option.dart';
import 'package:stelaris/feature/model/model_sort_option.dart';

class UpdateSearchQueryAction extends ReduxAction<AppState> {
  UpdateSearchQueryAction(this.query);

  final String query;

  @override
  AppState? reduce() {
    if (state.modelSearch.query == query) return null;
    return state.copyWith(modelSearch: state.modelSearch.copyWith(query: query));
  }
}

/// The list filter as the user types: only the last dispatch within the
/// pause reaches the store.
///
/// [DebouncedSearchQueryAction.cancel] shares the lock and changes nothing,
/// so dispatching it drops a query still waiting - for when the query is set
/// at once instead, cleared, or its field goes away.
class DebouncedSearchQueryAction extends ReduxAction<AppState> with Debounce {
  DebouncedSearchQueryAction(String this.query);

  DebouncedSearchQueryAction.cancel() : query = null;

  final String? query;

  @override
  int get debounce => 300;

  // Cancelling has to hit the same lock as the queries it drops.
  @override
  Object? lockBuilder() => DebouncedSearchQueryAction;

  @override
  AppState? reduce() {
    final String? query = this.query;
    if (query == null || state.modelSearch.query == query) return null;
    return state.copyWith(
      modelSearch: state.modelSearch.copyWith(query: query),
    );
  }
}

/// Clears query and active filters; sort order and section stay.
class ClearSearchAction extends ReduxAction<AppState> {
  @override
  AppState reduce() => state.copyWith(
    modelSearch: state.modelSearch.copyWith(query: '', activeFilters: {}),
  );
}

class ToggleSearchFilterAction extends ReduxAction<AppState> {
  ToggleSearchFilterAction(this.option);

  final FilterOption option;

  @override
  AppState reduce() {
    final active = Set<FilterOption>.of(state.modelSearch.activeFilters);
    active.contains(option) ? active.remove(option) : active.add(option);
    return state.copyWith(
      modelSearch: state.modelSearch.copyWith(activeFilters: active),
    );
  }
}

class UpdateSearchSortAction extends ReduxAction<AppState> {
  UpdateSearchSortAction(this.field, this.direction);

  final SortField field;
  final SortDirection direction;

  @override
  AppState reduce() => state.copyWith(
    modelSearch: state.modelSearch.copyWith(
      sortField: field,
      sortDirection: direction,
    ),
  );
}

/// Dispatched by a list page when it mounts, so the AppBar's filter menu
/// shows that page's filters. Active filters the page doesn't offer are
/// dropped, so a hidden filter can't keep narrowing the list.
///
/// A different [section] than before drops query, filters and sort — they
/// were set for the other section. Coming back from a detail page registers
/// the same section again and keeps them.
class RegisterSearchFiltersAction extends ReduxAction<AppState> {
  RegisterSearchFiltersAction(this.section, this.filters);

  final NavigationEntry section;
  final List<FilterOption> filters;

  @override
  AppState reduce() {
    final search = state.modelSearch;
    if (search.section != null && search.section != section) {
      return state.copyWith(
        modelSearch: ModelSearchState(
          section: section,
          availableFilters: filters,
        ),
      );
    }
    return state.copyWith(
      modelSearch: search.copyWith(
        section: section,
        availableFilters: filters,
        activeFilters: search.activeFilters.where(filters.contains).toSet(),
      ),
    );
  }
}
