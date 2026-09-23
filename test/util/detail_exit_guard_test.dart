import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/unsaved/unsaved_changes_guard.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/routes.dart';

Iterable<GoRoute> _goRoutes(List<RouteBase> routes) sync* {
  for (final route in routes) {
    if (route is GoRoute) yield route;
    yield* _goRoutes(route.routes);
  }
}

void main() {
  test('every detail route guards leaving it', () {
    final detailRoutes = _goRoutes(
      router.configuration.routes,
    ).where((route) => route.path == 'detail').toList();

    expect(detailRoutes, hasLength(4));
    for (final route in detailRoutes) {
      expect(route.onExit, same(detailExitGuard));
    }
  });

  group('detailExitGuard', () {
    late Store<AppState> store;
    late GoRouter testRouter;

    Future<void> pump(WidgetTester tester, AppState state) async {
      store = Store<AppState>(initialState: state);
      testRouter = GoRouter(
        initialLocation: '/items/detail',
        routes: [
          GoRoute(
            path: '/items',
            builder: (context, state) =>
                const Scaffold(body: Text('Item List')),
            routes: [
              GoRoute(
                path: 'detail',
                onExit: detailExitGuard,
                builder: (context, state) =>
                    const Scaffold(body: Text('Item Detail')),
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp.router(
            routerConfig: testRouter,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // A new location from outside the page — what the browser's back
    // button delivers on the web, which never consults PopScope.
    testWidgets('asks before a location change leaves unsaved edits', (
      tester,
    ) async {
      await pump(
        tester,
        const AppState(unsavedChanges: NavigationEntry.items),
      );

      testRouter.go('/items');
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.byKey(const Key('unsaved_dialog_cancel')));
      await tester.pumpAndSettle();
      expect(find.text('Item Detail'), findsOneWidget);

      testRouter.go('/items');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('unsaved_dialog_discard')));
      await tester.pumpAndSettle();
      expect(find.text('Item List'), findsOneWidget);
    });
  });
}
