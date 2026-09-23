import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/search_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/model_search_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/filter_option.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/feature/model/model_sort_option.dart';
import 'package:stelaris/l10n/app_localizations.dart';

import '../../test_model.dart';

/// Wraps a [ModelPage] of [models] in the store it reads its search,
/// filters and sort order from. The search field itself lives in the
/// AppBar (see AppBarSearch), so tests drive the list through [store].
Widget createModelPage({
  required Store<AppState> store,
  required List<TestModel> models,
  bool Function(TestModel, FilterOption)? matchesFilter,
  List<FilterOption> filterOptions = const [],
  VoidCallback? onAdd,
  VoidCallback? onRefresh,
  bool isRefreshing = false,
}) {
  return StoreProvider<AppState>(
    store: store,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ModelPage<TestModel>(
          entry: NavigationEntry.items,
          models: models,
          mapToDataModelItem: (m) => Text(m.name),
          deleteTitle: 'Delete test model',
          mapToDeleteSuccessfully: (_) => true,
          matchesSearch: (m, q) =>
              m.name.toLowerCase().contains(q.toLowerCase()),
          matchesFilter: matchesFilter ?? (_, _) => true,
          nameSelector: (m) => m.name,
          keySelector: (m) => m.internalId.toString(),
          projectKey: 'proj',
          filterOptions: filterOptions,
          onAdd: onAdd ?? () {},
          onModelTap: (_) {},
          onRefresh: onRefresh ?? () {},
          isRefreshing: isRefreshing,
        ),
      ),
    ),
  );
}

void main() {
  late Store<AppState> store;

  setUp(() => store = Store<AppState>(initialState: const AppState()));

  group('ModelPage filtering', () {
    const evenFilter = FilterOption('even', 'Even');

    final models = List.generate(
      5,
      (i) => TestModel(internalId: i, name: 'Model $i'),
    );

    testWidgets('a search query narrows the visible list', (tester) async {
      await tester.pumpWidget(createModelPage(store: store, models: models));

      expect(find.text('Model 0'), findsOneWidget);
      expect(find.text('Model 4'), findsOneWidget);

      store.dispatch(UpdateSearchQueryAction('Model 2'));
      await tester.pumpAndSettle();

      expect(find.text('Model 2'), findsOneWidget);
      expect(find.text('Model 0'), findsNothing);
      expect(find.text('Model 4'), findsNothing);
    });

    testWidgets('an active filter narrows the visible list', (tester) async {
      await tester.pumpWidget(
        createModelPage(
          store: store,
          models: models,
          filterOptions: const [evenFilter],
          matchesFilter: (model, filter) =>
              filter.id != 'even' || model.internalId.isEven,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Model 1'), findsOneWidget);

      store.dispatch(ToggleSearchFilterAction(evenFilter));
      await tester.pumpAndSettle();

      expect(find.text('Model 0'), findsOneWidget);
      expect(find.text('Model 2'), findsOneWidget);
      expect(find.text('Model 4'), findsOneWidget);
      expect(find.text('Model 1'), findsNothing);
      expect(find.text('Model 3'), findsNothing);
    });

    testWidgets('registers its filter options with the store', (tester) async {
      await tester.pumpWidget(
        createModelPage(
          store: store,
          models: models,
          filterOptions: const [evenFilter],
        ),
      );
      await tester.pumpAndSettle();

      expect(store.state.modelSearch.availableFilters, [evenFilter]);
    });

    testWidgets('shows the section name and model count in the header', (
      tester,
    ) async {
      await tester.pumpWidget(createModelPage(store: store, models: models));
      await tester.pumpAndSettle();

      expect(find.text('Items (5)'), findsOneWidget);
    });

    testWidgets('the add action calls onAdd', (tester) async {
      var added = false;
      await tester.pumpWidget(
        createModelPage(
          store: store,
          models: models,
          onAdd: () => added = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.add));

      expect(added, isTrue);
    });
  });

  group('ModelPage empty states', () {
    // Same empty-state copy (empty_data_header/empty_data_subHeader) the
    // other, not-yet-migrated pages already use for their "nothing to
    // show" case — reused here rather than inventing new strings.
    const emptyHeader = 'No data selected';

    testWidgets(
      'shows the shared empty-data hint when there are no models at all',
      (tester) async {
        await tester.pumpWidget(createModelPage(store: store, models: const []));

        expect(find.text(emptyHeader), findsOneWidget);
      },
    );

    testWidgets('shows the same hint when a search yields no results', (
      tester,
    ) async {
      await tester.pumpWidget(
        createModelPage(
          store: store,
          models: [TestModel(internalId: 1, name: 'Model 1')],
        ),
      );

      store.dispatch(UpdateSearchQueryAction('nope'));
      await tester.pumpAndSettle();

      expect(find.text(emptyHeader), findsOneWidget);
      expect(find.text('Model 1'), findsNothing);
    });
  });

  group('ModelPage sorting', () {
    // Dates deliberately don't align with alphabetical order, so a
    // date-based sort is distinguishable from the name-based default.
    final models = [
      TestModel(
        internalId: 1,
        name: 'Alpha',
        creationDate: DateTime(2024, 2, 1),
      ),
      TestModel(
        internalId: 2,
        name: 'Bravo',
        creationDate: DateTime(2024, 3, 1),
      ),
      TestModel(
        internalId: 3,
        name: 'Charlie',
        creationDate: DateTime(2024, 1, 1),
      ),
    ];

    List<String> visibleNameOrder(WidgetTester tester) {
      return tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .whereType<String>()
          .where(['Alpha', 'Bravo', 'Charlie'].contains)
          .toList();
    }

    Future<void> sortBy(
      WidgetTester tester,
      SortField field,
      SortDirection direction,
    ) async {
      store.dispatch(UpdateSearchSortAction(field, direction));
      await tester.pumpAndSettle();
    }

    testWidgets('defaults to name ascending', (tester) async {
      await tester.pumpWidget(createModelPage(store: store, models: models));
      await tester.pumpAndSettle();

      expect(visibleNameOrder(tester), ['Alpha', 'Bravo', 'Charlie']);
    });

    testWidgets('name descending reverses the default order', (tester) async {
      await tester.pumpWidget(createModelPage(store: store, models: models));

      await sortBy(tester, SortField.name, SortDirection.descending);

      expect(visibleNameOrder(tester), ['Charlie', 'Bravo', 'Alpha']);
    });

    testWidgets('sorts by creation date, oldest first', (tester) async {
      await tester.pumpWidget(createModelPage(store: store, models: models));

      await sortBy(tester, SortField.createdAt, SortDirection.ascending);

      expect(visibleNameOrder(tester), ['Charlie', 'Alpha', 'Bravo']);
    });

    testWidgets('sorts by creation date, newest first', (tester) async {
      await tester.pumpWidget(createModelPage(store: store, models: models));

      await sortBy(tester, SortField.createdAt, SortDirection.descending);

      expect(visibleNameOrder(tester), ['Bravo', 'Alpha', 'Charlie']);
    });

    testWidgets('keeps undated models last in both creation-date directions', (
      tester,
    ) async {
      final withUndated = [
        TestModel(
          internalId: 1,
          name: 'Alpha',
          creationDate: DateTime(2024, 2, 1),
        ),
        TestModel(internalId: 2, name: 'Bravo'), // no creationDate
        TestModel(
          internalId: 3,
          name: 'Charlie',
          creationDate: DateTime(2024, 1, 1),
        ),
      ];

      await tester.pumpWidget(
        createModelPage(store: store, models: withUndated),
      );

      // Oldest first: Bravo (no date) must stay last, not first.
      await sortBy(tester, SortField.createdAt, SortDirection.ascending);
      expect(visibleNameOrder(tester), ['Charlie', 'Alpha', 'Bravo']);

      // Newest first: Bravo (no date) must still stay last.
      await sortBy(tester, SortField.createdAt, SortDirection.descending);
      expect(visibleNameOrder(tester), ['Alpha', 'Charlie', 'Bravo']);
    });
  });

  group('ModelPage refresh', () {
    final models = [TestModel(internalId: 1, name: 'Model 1')];

    testWidgets('forwards a tap on the refresh button to onRefresh', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        createModelPage(
          store: store,
          models: models,
          onRefresh: () => tapped = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows a spinner in the refresh action while refreshing', (
      tester,
    ) async {
      await tester.pumpWidget(
        createModelPage(store: store, models: models, isRefreshing: true),
      );

      expect(find.byIcon(Icons.refresh), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('ModelPage search section', () {
    final models = [
      TestModel(internalId: 1, name: 'Ruby'),
      TestModel(internalId: 2, name: 'Emerald'),
    ];

    testWidgets('a search typed in another section is dropped', (tester) async {
      store = Store<AppState>(
        initialState: const AppState(
          modelSearch: ModelSearchState(
            section: NavigationEntry.font,
            query: 'ruby',
          ),
        ),
      );

      await tester.pumpWidget(createModelPage(store: store, models: models));
      await tester.pumpAndSettle();

      expect(store.state.modelSearch.query, '');
      expect(store.state.modelSearch.section, NavigationEntry.items);
      expect(find.text('Emerald'), findsOneWidget);
    });
  });
}
