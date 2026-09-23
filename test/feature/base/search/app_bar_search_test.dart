import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/search_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/model_search_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/search/app_bar_search.dart';
import 'package:stelaris/feature/model/filter_option.dart';
import 'package:stelaris/feature/model/model_sort_option.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  const filterA = FilterOption('a', 'Filter A');

  late Store<AppState> store;
  late GoRouter router;

  Future<void> pump(
    WidgetTester tester, {
    String location = '/items',
    AppState state = const AppState(),
    double width = 1000,
  }) async {
    store = Store<AppState>(initialState: state);
    Widget page(String label) => Scaffold(
      appBar: AppBar(title: const AppBarSearch()),
      body: Text(label),
    );
    router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/items',
          builder: (context, state) => page('Item List'),
          routes: [
            GoRoute(
              path: 'detail',
              builder: (context, state) => page('Item Detail'),
            ),
          ],
        ),
      ],
    );
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows a section-specific hint', (tester) async {
    await pump(tester);
    expect(find.text('Search Items...'), findsOneWidget);
  });

  testWidgets('dispatches the query only after the 300ms debounce', (
    tester,
  ) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), 'ruby');
    await tester.pump(const Duration(milliseconds: 250));
    expect(store.state.modelSearch.query, '');

    await tester.pump(const Duration(milliseconds: 100));
    expect(store.state.modelSearch.query, 'ruby');
  });

  testWidgets('clears the field when the store query is cleared', (
    tester,
  ) async {
    await pump(
      tester,
      state: const AppState(modelSearch: ModelSearchState(query: 'ruby')),
    );
    expect(find.text('ruby'), findsOneWidget);

    store.dispatch(UpdateSearchQueryAction(''));
    await tester.pumpAndSettle();

    expect(find.text('ruby'), findsNothing);
  });

  testWidgets('filter menu shows registered filters and a badge count', (
    tester,
  ) async {
    await pump(
      tester,
      state: const AppState(
        modelSearch: ModelSearchState(availableFilters: [filterA]),
      ),
    );

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filter A'));
    await tester.pumpAndSettle();

    expect(store.state.modelSearch.activeFilters, {filterA});
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('sort menu updates the store', (tester) async {
    await pump(tester);

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Name (Z–A)'));
    await tester.pumpAndSettle();

    expect(store.state.modelSearch.sortField, SortField.name);
    expect(store.state.modelSearch.sortDirection, SortDirection.descending);
  });

  testWidgets('collapses to an icon below 600px and expands on tap', (
    tester,
  ) async {
    await pump(tester, width: 500);

    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.byKey(const Key('app_bar_search_open')));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.byKey(const Key('app_bar_search_close')));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('typing on a clean detail page navigates to the list with '
      'the query', (tester) async {
    await pump(tester, location: '/items/detail');

    await tester.enterText(find.byType(TextField), 'ruby');
    await tester.pumpAndSettle();

    expect(find.text('Item List'), findsOneWidget);
    expect(store.state.modelSearch.query, 'ruby');
  });

  testWidgets('cancelling the guard on a dirty detail page restores the '
      'field and stays', (tester) async {
    await pump(
      tester,
      location: '/items/detail',
      state: const AppState(
        unsavedChanges: NavigationEntry.items,
        modelSearch: ModelSearchState(query: 'old'),
      ),
    );

    await tester.enterText(find.byType(TextField), 'oldx');
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    // Typing more while the dialog is open must not open a second dialog.
    await tester.enterText(find.byType(TextField), 'oldxy');
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.byKey(const Key('unsaved_dialog_cancel')));
    await tester.pumpAndSettle();

    expect(find.text('Item Detail'), findsOneWidget);
    expect(find.text('old'), findsOneWidget);
    expect(store.state.modelSearch.query, 'old');
  });

  testWidgets('discarding on a dirty detail page keeps everything typed', (
    tester,
  ) async {
    await pump(
      tester,
      location: '/items/detail',
      state: const AppState(unsavedChanges: NavigationEntry.items),
    );

    await tester.enterText(find.byType(TextField), 'r');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ruby');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('unsaved_dialog_discard')));
    await tester.pumpAndSettle();

    expect(find.text('Item List'), findsOneWidget);
    expect(store.state.modelSearch.query, 'ruby');
  });

  testWidgets('stands out from the AppBar: surface fill with an outline, '
      'primary outline when focused', (tester) async {
    await pump(tester);

    final context = tester.element(find.byType(SearchBar));
    final colorScheme = Theme.of(context).colorScheme;
    final bar = tester.widget<SearchBar>(find.byType(SearchBar));

    expect(bar.backgroundColor!.resolve({}), colorScheme.surface);
    expect(
      bar.side!.resolve({}),
      BorderSide(color: colorScheme.outlineVariant),
    );
    expect(
      bar.side!.resolve({WidgetState.focused}),
      BorderSide(color: colorScheme.primary, width: 2),
    );
  });

  testWidgets('the clear button and Esc empty the field and the query', (
    tester,
  ) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), 'ruby');
    await tester.pump(const Duration(milliseconds: 350));
    expect(store.state.modelSearch.query, 'ruby');

    await tester.tap(find.byKey(const Key('app_bar_search_clear')));
    await tester.pump();
    expect(store.state.modelSearch.query, '');
    expect(find.text('ruby'), findsNothing);

    await tester.enterText(find.byType(TextField), 'ruby');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(store.state.modelSearch.query, '');
    expect(find.text('ruby'), findsNothing);
  });
}
