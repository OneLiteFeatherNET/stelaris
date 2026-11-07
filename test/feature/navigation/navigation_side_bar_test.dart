import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris/api/state/actions/app_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/navigation/navigation_side_bar.dart';
import 'package:stelaris/feature/settings/settings_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';

/// The route of the expression detail page, nested below its section.
const _expressionDetailRoute = '/expression/detail';

GoRouter createTestRouter() {
  return GoRouter(
    initialLocation: sectionEntries.first.route,
    routes: [
      for (final entry in NavigationEntry.values)
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

/// Builds a router for every entry and asset page, plus the expression detail
/// route, each page showing its route as text next to the sidebar, so a test
/// can see where it has navigated.
GoRouter createRailTestRouter(String initialLocation) {
  final routes = [
    for (final entry in NavigationEntry.values) entry.route,
    for (final entry in AssetNavigationEntry.values) entry.route,
    for (final entry in BuildNavigationEntry.values) entry.route,
    _expressionDetailRoute,
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
  // The labels of the rail's destinations: the sections, the asset pages,
  // the runtime entries, then the build pages.
  final railDisplays = [
    for (final entry in sectionEntries) entry.display,
    for (final entry in AssetNavigationEntry.values) entry.display,
    for (final entry in runtimeNavigationEntries) entry.display,
    for (final entry in BuildNavigationEntry.values) entry.display,
  ];

  testWidgets('stays on the matching entry when on a nested detail route '
      '(regression: used to fall back to index 0 / Attributes)', (
    tester,
  ) async {
    final store = Store<AppState>(initialState: AppState.fromJson({}));
    final itemsIndex = sectionEntries.indexOf(NavigationEntry.items);

    final router = GoRouter(
      initialLocation: '${NavigationEntry.items.route}/detail',
      routes: [
        for (final entry in NavigationEntry.values)
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

    // The settings entry at the bottom of the rail shares the icon column.
    final iconOwners = [...railDisplays, 'Settings'];

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
          hasLength(iconOwners.length),
          reason: 'expected one icon per destination and one for settings',
        );
        final extendedColumn = extendedCenters.first;
        for (final (index, dx) in extendedCenters.indexed) {
          expect(
            dx,
            closeTo(extendedColumn, 0.5),
            reason:
                'extended: icon of ${iconOwners[index]} is at x=$dx '
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
                'mid-animation: icon of ${iconOwners[index]} moved to x=$dx '
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
                'collapsed: icon of ${iconOwners[index]} is at x=$dx '
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
        sectionEntries.length + 1 + AssetNavigationEntry.models.index;

    testWidgets('shows the heading when extended', (tester) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter('/items'), store),
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
        buildTestWidget(createRailTestRouter('/items'), store),
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
        buildTestWidget(createRailTestRouter('/items'), store),
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
        buildTestWidget(createRailTestRouter('/assets/models?id=m1'), store),
      );
      await tester.pumpAndSettle();

      expect(rail(tester).selectedIndex, modelsIndex);
    });

    testWidgets('tapping Models navigates to /assets/models', (tester) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter('/items'), store),
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
        buildTestWidget(createRailTestRouter('/sound'), store),
      );
      await tester.pumpAndSettle();

      expect(rail(tester).selectedIndex, NavigationEntry.sound.index);
      final destinations = rail(tester).destinations;
      expect(
        destinations,
        hasLength(
          sectionEntries.length +
              1 +
              AssetNavigationEntry.values.length +
              1 +
              runtimeNavigationEntries.length +
              1 +
              BuildNavigationEntry.values.length,
        ),
      );
      expect(destinations[sectionEntries.length].disabled, isTrue);
    });
  });

  group('runtime heading', () {
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

    // The Runtime heading comes after the Assets heading and its pages.
    final runtimeHeadingIndex =
        sectionEntries.length + 1 + AssetNavigationEntry.values.length;
    final expressionIndex =
        runtimeHeadingIndex +
        1 +
        runtimeNavigationEntries.indexOf(NavigationEntry.expression);

    testWidgets('shows the Runtime heading when extended', (tester) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();

      expect(find.text('Runtime'), findsOneWidget);
    });

    testWidgets('shows the Runtime heading when collapsed, not ellipsized', (
      tester,
    ) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();

      await tester.runAsync(
        () async => store.dispatch(UpdateNavigationAction()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Runtime'), findsOneWidget);
      expect(
        tester.getSize(find.text('Runtime')).width,
        lessThanOrEqualTo(80),
        reason: 'the heading must fit the 80 px collapsed icon column',
      );
    });

    testWidgets(
      'lists the expression tile below the heading, after the asset pages',
      (tester) async {
        useWideView(tester);
        final store = Store<AppState>(initialState: AppState.fromJson({}));
        await tester.pumpWidget(
          buildTestWidget(createRailTestRouter('/items'), store),
        );
        await tester.pumpAndSettle();

        final headingY = tester.getTopLeft(find.text('Runtime')).dy;
        expect(
          tester.getTopLeft(find.text('Models')).dy,
          lessThan(headingY),
          reason: 'the sections and asset pages come before the heading',
        );
        expect(
          tester.getTopLeft(find.text('Expressions')).dy,
          greaterThan(headingY),
          reason: 'the expression tile comes after the heading',
        );
      },
    );

    testWidgets('the heading is a disabled destination', (tester) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();

      final destinations = rail(tester).destinations;
      expect(
        destinations,
        hasLength(
          NavigationEntry.values.length +
              AssetNavigationEntry.values.length +
              BuildNavigationEntry.values.length +
              3,
        ),
        reason: 'the three headings are destinations beside the pages',
      );
      expect(destinations[runtimeHeadingIndex].disabled, isTrue);
    });

    testWidgets('tapping the heading does not navigate', (tester) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Runtime'));
      await tester.pumpAndSettle();

      expect(find.text('/items'), findsOneWidget);
      expect(find.text('/expression'), findsNothing);
      expect(rail(tester).selectedIndex, NavigationEntry.items.index);
    });

    testWidgets('highlights the expression tile on its detail route', (
      tester,
    ) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter(_expressionDetailRoute), store),
      );
      await tester.pumpAndSettle();

      expect(rail(tester).selectedIndex, expressionIndex);
    });

    testWidgets('tapping Expressions navigates to /expression', (tester) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Expressions'));
      await tester.pumpAndSettle();

      expect(find.text('/expression'), findsOneWidget);
      expect(rail(tester).selectedIndex, expressionIndex);
    });
  });

  group('build heading', () {
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

    // The Build heading comes after the Runtime heading and its pages.
    final buildHeadingIndex =
        sectionEntries.length +
        1 +
        AssetNavigationEntry.values.length +
        1 +
        runtimeNavigationEntries.length;
    final generatorIndex =
        buildHeadingIndex +
        1 +
        BuildNavigationEntry.values.indexOf(BuildNavigationEntry.generator);

    testWidgets('shows the Build heading when extended', (tester) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();

      expect(find.text('Build'), findsOneWidget);
    });

    testWidgets('lists the generator below the runtime entries', (
      tester,
    ) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();

      final headingY = tester.getTopLeft(find.text('Build')).dy;
      expect(
        tester.getTopLeft(find.text('Functions')).dy,
        lessThan(headingY),
        reason: 'the runtime entries come before the Build heading',
      );
      expect(
        tester.getTopLeft(find.text('Generator')).dy,
        greaterThan(headingY),
        reason: 'the generator comes after the Build heading',
      );
    });

    testWidgets('the heading is a disabled destination', (tester) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();

      expect(rail(tester).destinations[buildHeadingIndex].disabled, isTrue);
    });

    testWidgets('tapping the heading does not navigate', (tester) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Build'));
      await tester.pumpAndSettle();

      expect(find.text('/items'), findsOneWidget);
      expect(find.text('/generator'), findsNothing);
      expect(rail(tester).selectedIndex, NavigationEntry.items.index);
    });

    testWidgets('highlights the generator on its route', (tester) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter('/generator'), store),
      );
      await tester.pumpAndSettle();

      expect(rail(tester).selectedIndex, generatorIndex);
    });

    testWidgets('tapping Generator navigates to /generator', (tester) async {
      useWideView(tester);
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generator'));
      await tester.pumpAndSettle();

      expect(find.text('/generator'), findsOneWidget);
      expect(rail(tester).selectedIndex, generatorIndex);
    });
  });

  group('settings entry', () {
    // Width >= 1000 is required for the rail to be allowed to extend.
    void useWideView(WidgetTester tester) {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Future<void> pumpRail(WidgetTester tester) async {
      final store = Store<AppState>(initialState: AppState.fromJson({}));
      await tester.pumpWidget(
        buildTestWidget(createRailTestRouter('/items'), store),
      );
      await tester.pumpAndSettle();
    }

    NavigationRail rail(WidgetTester tester) =>
        tester.widget<NavigationRail>(find.byType(NavigationRail));

    testWidgets('tapping the icon opens the settings dialog', (tester) async {
      useWideView(tester);
      await pumpRail(tester);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDialog), findsOneWidget);
    });

    testWidgets('tapping the label opens the settings dialog, like a '
        'destination', (tester) async {
      useWideView(tester);
      await pumpRail(tester);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDialog), findsOneWidget);
    });

    testWidgets('keeps the current page selected', (tester) async {
      useWideView(tester);
      await pumpRail(tester);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('/items'), findsOneWidget);
      expect(rail(tester).selectedIndex, NavigationEntry.items.index);
    });

    testWidgets('has no tooltip of its own, like the destinations', (
      tester,
    ) async {
      useWideView(tester);
      await pumpRail(tester);

      expect(
        find.ancestor(
          of: find.byIcon(Icons.settings_outlined),
          matching: find.byType(Tooltip),
        ),
        findsNothing,
      );
    });
  });
}
