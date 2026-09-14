import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/base_page.dart';
import 'package:stelaris/feature/navigation/navigation_side_bar.dart';
import 'package:stelaris/util/routes.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('ShellRoute Routing Tests', () {
    const testProject = Project(
      id: 'proj_test_1',
      key: 'test_project',
      displayName: 'Test Project',
    );

    testWidgets(
      'navigating between feature routes keeps BasePage and NavigationSideBar mounted in ShellRoute',
      (WidgetTester tester) async {
        final store = Store<AppState>(
          initialState: const AppState().copyWith(selectedProject: testProject),
        );

        // Verify that the router's configuration contains a ShellRoute with the feature subroutes
        final shellRoutes = router.configuration.routes.whereType<ShellRoute>();
        expect(shellRoutes, isNotEmpty);

        final shell = shellRoutes.first;
        final subPaths = shell.routes
            .whereType<GoRoute>()
            .map((r) => r.path)
            .toList();

        expect(subPaths, contains(NavigationEntry.items.route));
        expect(subPaths, contains(NavigationEntry.attributes.route));
        expect(subPaths, contains(NavigationEntry.notifications.route));
        expect(subPaths, contains(NavigationEntry.font.route));
        expect(subPaths, contains(NavigationEntry.sound.route));

        // Create an isolated GoRouter configured with ShellRoute for widget testing
        final testRouter = GoRouter(
          initialLocation: NavigationEntry.items.route,
          routes: [
            ShellRoute(
              builder: (context, state, child) => BasePage(child: child),
              routes: [
                GoRoute(
                  path: NavigationEntry.items.route,
                  builder: (context, state) =>
                      const Scaffold(body: Text('Items Feature Content')),
                ),
                GoRoute(
                  path: NavigationEntry.sound.route,
                  builder: (context, state) =>
                      const Scaffold(body: Text('Sound Feature Content')),
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          StoreProvider<AppState>(
            store: store,
            child: MaterialApp.router(routerConfig: testRouter),
          ),
        );
        await tester.pumpAndSettle();

        // Initially at /items: BasePage, NavigationSideBar, and Items content are visible
        expect(find.byType(BasePage), findsOneWidget);
        expect(find.byType(NavigationSideBar), findsOneWidget);
        expect(find.text('Items Feature Content'), findsOneWidget);

        // Check selected index on NavigationRail
        final railFinder = find.byType(NavigationRail);
        expect(railFinder, findsOneWidget);
        final NavigationRail railInitial = tester.widget(railFinder);
        final expectedItemsIndex = NavigationEntry.values.indexOf(
          NavigationEntry.items,
        );
        expect(railInitial.selectedIndex, equals(expectedItemsIndex));

        // Navigate to /sound
        testRouter.go(NavigationEntry.sound.route);
        await tester.pumpAndSettle();

        // BasePage and NavigationSideBar remain mounted (1 instance)
        expect(find.byType(BasePage), findsOneWidget);
        expect(find.byType(NavigationSideBar), findsOneWidget);
        expect(find.text('Sound Feature Content'), findsOneWidget);
        expect(find.text('Items Feature Content'), findsNothing);

        // NavigationRail selected index updated to Sound
        final NavigationRail railUpdated = tester.widget(railFinder);
        final expectedSoundIndex = NavigationEntry.values.indexOf(
          NavigationEntry.sound,
        );
        expect(railUpdated.selectedIndex, equals(expectedSoundIndex));
      },
    );
  });
}
