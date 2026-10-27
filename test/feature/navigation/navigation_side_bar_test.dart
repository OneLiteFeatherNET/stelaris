import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris/api/state/actions/app_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
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

/// Builds a router for every section and asset page, each showing its route
/// as text next to the sidebar, so a test can see where it has navigated.
GoRouter createAssetTestRouter(String initialLocation) {
  final routes = [
    for (final entry in navigationEntries) entry.route,
    for (final entry in AssetNavigationEntry.values) entry.route,
  ];
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      for (final route in routes)
        GoRoute(
          path: route,
          builder: (context, state) => Scaffold(
            body: Row(
              children: [
                const NavigationSideBar(),
                Expanded(child: Text(route)),
              ],
            ),
          ),
        ),
    ],
  );
}

void main() {
  // The labels of the rail's destinations, sections first, then the asset pages.
  final railDisplays = [
    for (final entry in navigationEntries) entry.display,
    for (final entry in AssetNavigationEntry.values) entry.display,
  ];

  testWidgets('stays on the matching entry when on a nested detail route '
      '(regression: used to fall back to index 0 / Attributes)', (
    tester,
  ) async {
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
  });

  group('icon column', () {
    // Width >= 1000 is required for the rail to be allowed to extend.
    const railTestWidth = 1200.0;
    const railTestHeight = 800.0;

    List<double> iconCentersX(WidgetTester tester) {
      return [
        for (final icon in tester.widgetList<Icon>(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.byType(Icon),
          ),
        ))
          tester.getCenter(find.byWidget(icon)).dx,
      ];
    }

    testWidgets(
      'keeps all destination icons in one column when extended, collapsed and mid-animation',
      (tester) async {
        tester.view.physicalSize = const Size(railTestWidth, railTestHeight);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final store = Store<AppState>(initialState: AppState.fromJson({}));
        await tester.pumpWidget(buildTestWidget(createTestRouter(), store));
        await tester.pumpAndSettle();

        final extendedCenters = iconCentersX(tester);
        expect(
          extendedCenters,
          hasLength(railDisplays.length),
          reason: 'expected one icon per navigation destination',
        );
        final extendedColumn = extendedCenters.first;
        for (final (index, dx) in extendedCenters.indexed) {
          expect(
            dx,
            closeTo(extendedColumn, 0.5),
            reason:
                'extended: icon of ${railDisplays[index]} is at x=$dx '
                'but the first icon is at x=$extendedColumn',
          );
        }

        const duration = kThemeAnimationDuration;
        await tester.runAsync(
          () async => store.dispatch(UpdateNavigationAction()),
        );
        await tester.pump();
        await tester.pump(duration ~/ 2);
        expect(
          tester.takeException(),
          isNull,
          reason: 'no layout error (e.g. RenderFlex overflow) mid-animation',
        );
        final midCenters = iconCentersX(tester);
        for (final (index, dx) in midCenters.indexed) {
          expect(
            dx,
            closeTo(extendedColumn, 0.5),
            reason:
                'mid-animation: icon of ${railDisplays[index]} moved to x=$dx '
                'instead of staying in the column at x=$extendedColumn',
          );
        }

        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'no layout error (e.g. RenderFlex overflow) when collapsed',
        );
        final collapsedCenters = iconCentersX(tester);
        for (final (index, dx) in collapsedCenters.indexed) {
          expect(
            dx,
            closeTo(extendedColumn, 0.5),
            reason:
                'collapsed: icon of ${railDisplays[index]} is at x=$dx '
                'but the extended column is at x=$extendedColumn',
          );
        }
      },
    );

    testWidgets(
      'label is transparent a quarter into expanding and fully opaque when extended',
      (tester) async {
        tester.view.physicalSize = const Size(railTestWidth, railTestHeight);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        double labelOpacity() {
          final fade = tester.widget<FadeTransition>(
            find
                .ancestor(
                  of: find.text('Items'),
                  matching: find.byType(FadeTransition),
                )
                .first,
          );
          return fade.opacity.value;
        }

        final store = Store<AppState>(initialState: AppState.fromJson({}));
        await tester.pumpWidget(buildTestWidget(createTestRouter(), store));
        await tester.pumpAndSettle();

        await tester.runAsync(
          () async => store.dispatch(UpdateNavigationAction()),
        );
        await tester.pumpAndSettle();

        const duration = kThemeAnimationDuration;
        await tester.runAsync(
          () async => store.dispatch(UpdateNavigationAction()),
        );
        await tester.pump();
        await tester.pump(duration ~/ 4);
        expect(
          labelOpacity(),
          0,
          reason: 'label must be invisible a quarter into expanding',
        );

        await tester.pumpAndSettle();
        expect(
          labelOpacity(),
          1,
          reason: 'label must be fully opaque when the rail is extended',
        );
      },
    );
  });

  group('assets heading', () {
    // Width >= 1000 is required for the rail to be allowed to extend.
    const railTestWidth = 1200.0;
    const railTestHeight = 800.0;

    void useWideView(WidgetTester tester) {
      tester.view.physicalSize = const Size(railTestWidth, railTestHeight);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    NavigationRail rail(WidgetTester tester) =>
        tester.widget<NavigationRail>(find.byType(NavigationRail));

    final modelsIndex =
        NavigationEntry.values.length + 1 + AssetNavigationEntry.models.index;

    testWidgets('shows the heading when extended', (tester) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createAssetTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();

      expect(find.text('Assets'), findsOneWidget);
    });

    testWidgets('shows the heading when collapsed, not ellipsized', (
      tester,
    ) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createAssetTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();

      await tester.runAsync(
        () async => store.dispatch(UpdateNavigationAction()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Assets'), findsOneWidget);
      expect(
        tester.getSize(find.text('Assets')).width,
        lessThanOrEqualTo(80),
        reason: 'the heading must fit the 80 px collapsed icon column',
      );
    });

    testWidgets('tapping the heading does not navigate', (tester) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createAssetTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Assets'));
      await tester.pumpAndSettle();

      expect(find.text('/items'), findsOneWidget);
      expect(find.text('/assets/models'), findsNothing);
      expect(rail(tester).selectedIndex, NavigationEntry.items.index);
    });

    testWidgets('highlights Models on its route with a selection', (
      tester,
    ) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createAssetTestRouter('/assets/models?id=m1'), store),
      );
      await tester.pumpAndSettle();

      expect(rail(tester).selectedIndex, modelsIndex);
    });

    testWidgets('tapping Models navigates to /assets/models', (tester) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createAssetTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Models'));
      await tester.pumpAndSettle();

      expect(find.text('/assets/models'), findsOneWidget);
      expect(rail(tester).selectedIndex, modelsIndex);
    });

    testWidgets('keeps the section indices and puts the heading after them', (
      tester,
    ) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createAssetTestRouter('/sound'), store),
      );
      await tester.pumpAndSettle();

      expect(rail(tester).selectedIndex, NavigationEntry.sound.index);
      final destinations = rail(tester).destinations;
      expect(
        destinations,
        hasLength(
          navigationEntries.length + 1 + AssetNavigationEntry.values.length,
        ),
      );
      expect(destinations[navigationEntries.length].disabled, isTrue);
    });
  });
}
