import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/model_search_state.dart';
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
class RegisterSearchFiltersAction extends ReduxAction<AppState> {
  RegisterSearchFiltersAction(this.filters);

  final List<FilterOption> filters;

  @override
  AppState reduce() => state.copyWith(
    modelSearch: state.modelSearch.copyWith(
      availableFilters: filters,
      activeFilters: state.modelSearch.activeFilters
          .where(filters.contains)
          .toSet(),
    ),
  );
}

/// Dispatched when switching to a different navigation section — a query
/// typed for items means nothing for fonts.
class ResetSearchAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    if (state.modelSearch == const ModelSearchState()) return null;
    return state.copyWith(modelSearch: const ModelSearchState());
  }
}
