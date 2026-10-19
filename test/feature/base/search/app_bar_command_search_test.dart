@Tags(['web'])
library;

import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/model_search_state.dart';
import 'package:stelaris/feature/command_palette/command_panel.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/palette.dart';

/// The app bar search inside the palette shortcut, as the shell has it.
Future<Store<AppState>> _pump(
  WidgetTester tester, {
  double width = 1600,
  AppState? state,
}) async {
  final store = Store<AppState>(
    initialState:
        state ??
        AppState(
          themeSettings: ThemeSettings.defaultSettings().copyWith(
            isDarkMode: false,
            useSystemTheme: false,
          ),
          items: pageOf(const [ItemModel(uiName: 'Diamond Sword', id: 'i1')]),
        ),
  );
  await pumpPaletteShell(
    tester,
    store,
    pages: [
      GoRoute(path: '/items', builder: (_, _) => const Text('Item List')),
    ],
    at: '/items',
    width: width,
  );
  return store;
}

void main() {
  testWidgets('Enter on plain text keeps the filter and closes the dropdown', (
    tester,
  ) async {
    final store = await _pump(tester);
    await pressCtrlK(tester);
    await tester.enterText(paletteField, 'sword');
    await tester.pump();
    expect(find.text('Filter Items by “sword”'), findsOneWidget);

    await pressKey(tester, LogicalKeyboardKey.enter);

    expect(find.byType(CommandPanel), findsNothing);
    expect(store.state.modelSearch.query, 'sword');
    expect(find.text('Item List'), findsOneWidget);

    // Let the list filter's debounce run out: async_redux's Debounce waits
    // on a Future.delayed that nothing can cancel.
    await tester.pump(const Duration(milliseconds: 350));
  });

  testWidgets('Down then Enter runs a command instead', (tester) async {
    final store = await _pump(tester);
    await pressCtrlK(tester);
    await tester.enterText(paletteField, 'dark');
    await tester.pumpAndSettle();

    await pressKey(tester, LogicalKeyboardKey.arrowDown);
    await pressKey(tester, LogicalKeyboardKey.enter);

    expect(store.state.themeSettings.isDarkMode, isTrue);
  });

  testWidgets('a prefix leaves the list filter alone', (tester) async {
    final store = await _pump(
      tester,
      state: const AppState(modelSearch: ModelSearchState(query: 'old')),
    );
    await pressCtrlK(tester);

    await tester.enterText(paletteField, '#sword');
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

    await pressCtrlK(tester);

    expect(find.byKey(const Key('app_bar_search_open')), findsNothing);
    expect(find.byType(CommandPanel), findsOneWidget);
  });

  testWidgets('after a command the field shows the list filter again, plain', (
    tester,
  ) async {
    await _pump(
      tester,
      state: const AppState(modelSearch: ModelSearchState(query: 'old')),
    );
    await pressCtrlK(tester);
    await tester.enterText(paletteField, '>toggle dark');
    await tester.pumpAndSettle();

    await pressKey(tester, LogicalKeyboardKey.enter);

    expect(find.byKey(const Key('command-palette-mode-chip')), findsNothing);
    expect(tester.widget<TextField>(paletteField).controller!.text, 'old');
  });

  testWidgets('Ctrl+K still opens after a command ran', (tester) async {
    await _pump(tester);
    await pressCtrlK(tester);
    await tester.enterText(paletteField, '>toggle dark');
    await tester.pumpAndSettle();
    await pressKey(tester, LogicalKeyboardKey.enter);
    expect(find.byType(CommandPanel), findsNothing);

    await pressCtrlK(tester);

    expect(find.byType(CommandPanel), findsOneWidget);
  });

  testWidgets('Ctrl+K still opens after the field lost focus', (tester) async {
    await _pump(tester);
    await pressCtrlK(tester);
    await pressKey(tester, LogicalKeyboardKey.escape);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await pressCtrlK(tester);

    expect(find.byType(CommandPanel), findsOneWidget);
  });

  testWidgets('a plain keystroke leaves the SearchBar alone; a prefix '
      'rebuilds it for the chip', (tester) async {
    await _pump(tester);
    await pressCtrlK(tester);
    await tester.enterText(paletteField, 's');
    await tester.pump();
    final SearchBar before = tester.widget<SearchBar>(find.byType(SearchBar));

    // Before the debounce hands the text to the store.
    await tester.enterText(paletteField, 'sw');
    await tester.pump();
    expect(
      identical(tester.widget<SearchBar>(find.byType(SearchBar)), before),
      isTrue,
    );

    await tester.enterText(paletteField, '#');
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
