import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/search/app_bar_search.dart';
import 'package:stelaris/feature/command_palette/command_palette.dart';
import 'package:stelaris/feature/command_palette/command_panel.dart';
import 'package:stelaris/feature/command_palette/command_registry.dart';
import 'package:stelaris/feature/command_palette/entity_search_source.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// [items] as the only page of a list.
PaginatedResult<T> pageOf<T>(List<T> items) => PaginatedResult<T>(
  items: items,
  totalItems: items.length,
  totalPages: 1,
  currentPage: 1,
  pageSize: 10,
);

/// The lists the palette tests move between, with detail pages for items and
/// attributes.
List<RouteBase> palettePages() => [
  GoRoute(path: '/fonts', builder: (_, _) => const Text('fonts page')),
  GoRoute(
    path: '/items',
    builder: (_, _) => const Text('items page'),
    routes: [
      GoRoute(path: 'detail', builder: (_, _) => const Text('item detail')),
    ],
  ),
  GoRoute(
    path: '/attributes',
    builder: (_, _) => const Text('attributes page'),
    routes: [
      GoRoute(
        path: 'detail',
        builder: (_, _) => const Text('attribute detail'),
      ),
    ],
  ),
];

/// Pumps [pages] at [at] in the shell the app has: the palette shortcut
/// around a page with the app bar search, [outside] next to it.
Future<GoRouter> pumpPaletteShell(
  WidgetTester tester,
  Store<AppState> store, {
  required List<RouteBase> pages,
  required String at,
  List<RouteBase> outside = const [],
  CommandRegistry? registry,
  EntitySearchSource? entitySearch,
  double width = 1600,
}) async {
  // Wide enough for the full search field instead of the compact icon.
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: at,
    routes: [
      ShellRoute(
        builder: (context, state, child) => CommandPaletteShortcuts(
          registry: registry,
          entitySearch: entitySearch,
          child: Scaffold(
            appBar: AppBar(title: const AppBarSearch()),
            body: child,
          ),
        ),
        routes: pages,
      ),
      ...outside,
    ],
  );
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
  return router;
}

/// Presses Ctrl+K, which opens the palette or closes an open one.
Future<void> pressCtrlK(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

/// Presses [key] and lets the palette settle.
Future<void> pressKey(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

/// The text field of the app bar search, which the palette types into.
Finder get paletteField => find.descendant(
  of: find.byType(AppBarSearch),
  matching: find.byType(TextField),
);

/// The chip that holds the mode of the palette.
Finder get modeChip => find.byKey(const Key('command-palette-mode-chip'));

/// Types [text] into the palette and lets it settle.
Future<void> typeInPalette(WidgetTester tester, String text) async {
  await tester.enterText(paletteField, text);
  await tester.pumpAndSettle();
}

/// The titles of the entries the palette lists, in order.
List<String> paletteTitles(WidgetTester tester) => tester
    .widgetList<ListTile>(
      find.descendant(
        of: find.byType(CommandPanel),
        matching: find.byType(ListTile),
      ),
    )
    .map((tile) => (tile.title! as Text).data!)
    .toList();

/// Whether the entry titled [title] is the highlighted one.
bool isHighlighted(WidgetTester tester, String title) => tester
    .widget<ListTile>(
      find.ancestor(of: find.text(title), matching: find.byType(ListTile)),
    )
    .selected;
