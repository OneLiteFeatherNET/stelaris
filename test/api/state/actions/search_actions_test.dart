import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/actions/search_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/model_search_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/filter_option.dart';
import 'package:stelaris/feature/model/model_sort_option.dart';

void main() {
  const filterA = FilterOption('a', 'Filter A');
  const filterB = FilterOption('b', 'Filter B');

  late Store<AppState> store;

  setUp(() => store = Store<AppState>(initialState: const AppState()));

  test('defaults to an empty query sorted by name ascending', () {
    expect(store.state.modelSearch, const ModelSearchState());
    expect(store.state.modelSearch.query, '');
    expect(store.state.modelSearch.sortField, SortField.name);
    expect(store.state.modelSearch.sortDirection, SortDirection.ascending);
  });

  test('UpdateSearchQueryAction stores the query', () async {
    await store.dispatchAndWait(UpdateSearchQueryAction('ruby'));
    expect(store.state.modelSearch.query, 'ruby');
  });

  test('ToggleSearchFilterAction adds and removes a filter', () async {
    await store.dispatchAndWait(ToggleSearchFilterAction(filterA));
    await store.dispatchAndWait(ToggleSearchFilterAction(filterB));
    expect(store.state.modelSearch.activeFilters, {filterA, filterB});

    await store.dispatchAndWait(ToggleSearchFilterAction(filterA));
    expect(store.state.modelSearch.activeFilters, {filterB});
  });

  test('UpdateSearchSortAction stores field and direction', () async {
    await store.dispatchAndWait(
      UpdateSearchSortAction(SortField.createdAt, SortDirection.descending),
    );
    expect(store.state.modelSearch.sortField, SortField.createdAt);
    expect(store.state.modelSearch.sortDirection, SortDirection.descending);
  });

  test('registering drops active filters that are no longer offered',
      () async {
    await store.dispatchAndWait(
      RegisterSearchFiltersAction(NavigationEntry.items, [filterA, filterB]),
    );
    await store.dispatchAndWait(ToggleSearchFilterAction(filterA));
    await store.dispatchAndWait(ToggleSearchFilterAction(filterB));

    await store.dispatchAndWait(
      RegisterSearchFiltersAction(NavigationEntry.items, [filterB]),
    );

    expect(store.state.modelSearch.availableFilters, [filterB]);
    expect(store.state.modelSearch.activeFilters, {filterB});
  });

  test('the first registration keeps a search typed before it', () async {
    await store.dispatchAndWait(UpdateSearchQueryAction('ruby'));

    await store.dispatchAndWait(
      RegisterSearchFiltersAction(NavigationEntry.items, const []),
    );

    expect(store.state.modelSearch.section, NavigationEntry.items);
    expect(store.state.modelSearch.query, 'ruby');
  });

  test('registering the same section again keeps the search', () async {
    await store.dispatchAndWait(
      RegisterSearchFiltersAction(NavigationEntry.items, const []),
    );
    await store.dispatchAndWait(UpdateSearchQueryAction('ruby'));

    await store.dispatchAndWait(
      RegisterSearchFiltersAction(NavigationEntry.items, const []),
    );

    expect(store.state.modelSearch.query, 'ruby');
  });

  test('registering another section resets query, filters and sort', () async {
    await store.dispatchAndWait(
      RegisterSearchFiltersAction(NavigationEntry.items, [filterA]),
    );
    await store.dispatchAndWait(UpdateSearchQueryAction('ruby'));
    await store.dispatchAndWait(ToggleSearchFilterAction(filterA));
    await store.dispatchAndWait(
      UpdateSearchSortAction(SortField.createdAt, SortDirection.descending),
    );

    await store.dispatchAndWait(
      RegisterSearchFiltersAction(NavigationEntry.font, [filterB]),
    );

    expect(
      store.state.modelSearch,
      const ModelSearchState(
        section: NavigationEntry.font,
        availableFilters: [filterB],
      ),
    );
  });
}
