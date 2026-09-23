import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/filter_option.dart';
import 'package:stelaris/feature/model/model_sort_option.dart';

part 'model_search_state.freezed.dart';

/// The search/filter/sort choices shared by the AppBar search field and the
/// currently shown [ModelPage] list. Lives in the store (rather than in the
/// list page's own State) because the field that edits it sits in the
/// AppBar, outside the page it filters.
@Freezed(makeCollectionsUnmodifiable: false)
abstract class ModelSearchState with _$ModelSearchState {
  const factory ModelSearchState({
    @Default('') String query,
    @Default(<FilterOption>{}) Set<FilterOption> activeFilters,

    /// The filters the current list page offers, registered by that page —
    /// the AppBar has no other way to know which ones apply.
    @Default(<FilterOption>[]) List<FilterOption> availableFilters,
    @Default(SortField.name) SortField sortField,
    @Default(SortDirection.ascending) SortDirection sortDirection,

    /// The section the search was typed for. Lets the AppBar search notice
    /// a section change however it happens (side bar, browser back, URL).
    NavigationEntry? section,
  }) = _ModelSearchState;
}
