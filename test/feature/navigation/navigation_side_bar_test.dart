import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/model_search_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/navigation/navigation_side_bar.dart';
import 'package:stelaris/l10n/app_localizations.dart';

GoRouter createTestRouter() {
  return GoRouter(
    initialLocation: navigationEntries.first.route,
    routes: [
      for (final entry in navigationEntries)
        GoRoute(
          path: entry.route,
          builder: (context, state) {
            return Scaffold(
              body: Row(
                children: [
                  const NavigationSideBar(),
                  Expanded(child: Text(entry.display)),
                ],
              ),
            );
          },
        ),
    ],
  );
}

Widget buildTestWidget(GoRouter router, Store<AppState> store) {
  return StoreProvider<AppState>(
    store: store,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  testWidgets('shows correct selected index based on route', (tester) async {
    // Creates an empty store
    final store = Store<AppState>(initialState: AppState.fromJson({}));
    final router = createTestRouter();

    await tester.pumpWidget(buildTestWidget(router, store));
    await tester.pumpAndSettle();

    // NavigationRail should exist
    expect(find.byType(NavigationRail), findsOneWidget);

    // First route is selected by default
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 0);
  });

  testWidgets(
    'stays on the matching entry when on a nested detail route '
    '(regression: used to fall back to index 0 / Attributes)',
    (tester) async {
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      final itemsIndex = navigationEntries.indexOf(NavigationEntry.items);

      final router = GoRouter(
        initialLocation: '${NavigationEntry.items.route}/detail',
        routes: [
          for (final entry in navigationEntries)
            GoRoute(
              path: entry.route,
              builder: (context, state) => Scaffold(
                body: Row(
                  children: [
                    const NavigationSideBar(),
                    Expanded(child: Text(entry.display)),
                  ],
                ),
              ),
              routes: entry == NavigationEntry.items
                  ? [
                      GoRoute(
                        path: 'detail',
                        builder: (context, state) => const Scaffold(
                          body: Row(
                            children: [
                              NavigationSideBar(),
                              Expanded(child: Text('Item Detail')),
                            ],
                          ),
                        ),
                      ),
                    ]
                  : [],
            ),
        ],
      );

      await tester.pumpWidget(buildTestWidget(router, store));
      await tester.pumpAndSettle();

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.selectedIndex, itemsIndex);
    },
  );

  testWidgets('asks before leaving a detail page with unsaved changes', (
    tester,
  ) async {
    final store = Store<AppState>(
      initialState: const AppState(unsavedChanges: NavigationEntry.items),
    );
    final router = GoRouter(
      initialLocation: '${NavigationEntry.items.route}/detail',
      routes: [
        for (final entry in navigationEntries)
          GoRoute(
            path: entry.route,
            builder: (context, state) => Scaffold(
              body: Row(
                children: [
                  const NavigationSideBar(),
                  Expanded(child: Text(entry.display)),
                ],
              ),
            ),
            routes: entry == NavigationEntry.items
                ? [
                    GoRoute(
                      path: 'detail',
                      builder: (context, state) => const Scaffold(
                        body: Row(
                          children: [
                            NavigationSideBar(),
                            Expanded(child: Text('Item Detail')),
                          ],
                        ),
                      ),
                    ),
                  ]
                : const [],
          ),
      ],
    );

    await tester.pumpWidget(buildTestWidget(router, store));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(NavigationEntry.font.data));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.byKey(const Key('unsaved_dialog_cancel')));
    await tester.pumpAndSettle();
    expect(find.text('Item Detail'), findsOneWidget);
  });

  testWidgets('switching to another section resets the search', (
    tester,
  ) async {
    final store = Store<AppState>(
      initialState: const AppState(
        modelSearch: ModelSearchState(query: 'ruby'),
      ),
    );
    final router = createTestRouter();

    await tester.pumpWidget(buildTestWidget(router, store));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(NavigationEntry.font.data));
    await tester.pumpAndSettle();

    expect(store.state.modelSearch.query, '');
  });
}
