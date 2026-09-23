import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/model_search_state.dart';
import 'package:stelaris/feature/base/search/app_bar_search.dart';
import 'package:stelaris/feature/command_palette/command_palette.dart';
import 'package:stelaris/feature/command_palette/command_panel.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The app bar search inside the palette shortcut, as the shell has it.
Future<Store<AppState>> _pump(
  WidgetTester tester, {
  double width = 1600,
  AppState? state,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final store = Store<AppState>(
    initialState:
        state ??
        AppState(
          themeSettings: ThemeSettings.defaultSettings().copyWith(
            isDarkMode: false,
            useSystemTheme: false,
          ),
          items: const PaginatedResult<ItemModel>(
            items: [ItemModel(uiName: 'Diamond Sword', id: 'i1')],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
  );
  final router = GoRouter(
    initialLocation: '/items',
    routes: [
      ShellRoute(
        builder: (context, state, child) => CommandPaletteShortcuts(
          child: Scaffold(
            appBar: AppBar(title: const AppBarSearch()),
            body: child,
          ),
        ),
        routes: [
          GoRoute(path: '/items', builder: (_, _) => const Text('Item List')),
        ],
      ),
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
  return store;
}

Finder get _field => find.descendant(
  of: find.byType(AppBarSearch),
  matching: find.byType(TextField),
);

Future<void> _ctrlK(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Enter on plain text keeps the filter and closes the dropdown', (
    tester,
  ) async {
    final store = await _pump(tester);
    await _ctrlK(tester);
    await tester.enterText(_field, 'sword');
    await tester.pump();
    expect(find.text('Filter Items by “sword”'), findsOneWidget);

    await _press(tester, LogicalKeyboardKey.enter);

    expect(find.byType(CommandPanel), findsNothing);
    expect(store.state.modelSearch.query, 'sword');
    expect(find.text('Item List'), findsOneWidget);

    // Let the list filter's debounce run out: async_redux's Debounce waits
    // on a Future.delayed that nothing can cancel.
    await tester.pump(const Duration(milliseconds: 350));
  });

  testWidgets('Down then Enter runs a command instead', (tester) async {
    final store = await _pump(tester);
    await _ctrlK(tester);
    await tester.enterText(_field, 'dark');
    await tester.pumpAndSettle();

    await _press(tester, LogicalKeyboardKey.arrowDown);
    await _press(tester, LogicalKeyboardKey.enter);

    expect(store.state.themeSettings.isDarkMode, isTrue);
  });

  testWidgets('a prefix leaves the list filter alone', (tester) async {
    final store = await _pump(
      tester,
      state: const AppState(modelSearch: ModelSearchState(query: 'old')),
    );
    await _ctrlK(tester);

    await tester.enterText(_field, '#sword');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(store.state.modelSearch.query, 'old');
    expect(find.text('Filter Items by “#sword”'), findsNothing);
  });

  testWidgets('Ctrl+K expands the collapsed field and opens the dropdown', (
    tester,
  ) async {
    await _pump(tester, width: 500);
    expect(find.byKey(const Key('app_bar_search_open')), findsOneWidget);

    await _ctrlK(tester);

    expect(find.byKey(const Key('app_bar_search_open')), findsNothing);
    expect(find.byType(CommandPanel), findsOneWidget);
  });

  testWidgets('Ctrl+K again closes the dropdown', (tester) async {
    await _pump(tester);
    await _ctrlK(tester);
    expect(find.byType(CommandPanel), findsOneWidget);

    await _ctrlK(tester);

    expect(find.byType(CommandPanel), findsNothing);
  });

  testWidgets('after a command the field shows the list filter again, plain', (
    tester,
  ) async {
    await _pump(
      tester,
      state: const AppState(modelSearch: ModelSearchState(query: 'old')),
    );
    await _ctrlK(tester);
    await tester.enterText(_field, '>toggle dark');
    await tester.pumpAndSettle();

    await _press(tester, LogicalKeyboardKey.enter);

    expect(find.byKey(const Key('command-palette-mode-chip')), findsNothing);
    expect(tester.widget<TextField>(_field).controller!.text, 'old');
  });

  testWidgets('Ctrl+K still opens after a command ran', (tester) async {
    await _pump(tester);
    await _ctrlK(tester);
    await tester.enterText(_field, '>toggle dark');
    await tester.pumpAndSettle();
    await _press(tester, LogicalKeyboardKey.enter);
    expect(find.byType(CommandPanel), findsNothing);

    await _ctrlK(tester);

    expect(find.byType(CommandPanel), findsOneWidget);
  });

  testWidgets('Ctrl+K still opens after the field lost focus', (tester) async {
    await _pump(tester);
    await _ctrlK(tester);
    await _press(tester, LogicalKeyboardKey.escape);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await _ctrlK(tester);

    expect(find.byType(CommandPanel), findsOneWidget);
  });

  testWidgets('a plain keystroke leaves the SearchBar alone; a prefix '
      'rebuilds it for the chip', (tester) async {
    await _pump(tester);
    await _ctrlK(tester);
    await tester.enterText(_field, 's');
    await tester.pump();
    final SearchBar before = tester.widget<SearchBar>(find.byType(SearchBar));

    // Before the debounce hands the text to the store.
    await tester.enterText(_field, 'sw');
    await tester.pump();
    expect(
      identical(tester.widget<SearchBar>(find.byType(SearchBar)), before),
      isTrue,
    );

    await tester.enterText(_field, '#');
    await tester.pump();
    expect(
      identical(tester.widget<SearchBar>(find.byType(SearchBar)), before),
      isFalse,
    );
    expect(find.byKey(const Key('command-palette-mode-chip')), findsOneWidget);

    // Let the list filter's debounce run out: async_redux's Debounce waits
    // on a Future.delayed that nothing can cancel.
    await tester.pump(const Duration(milliseconds: 350));
  });
}
