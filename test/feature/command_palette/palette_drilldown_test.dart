import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/command_palette/command_palette.dart';
import 'package:stelaris/feature/command_palette/command_panel.dart';
import 'package:stelaris/feature/base/search/app_bar_search.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

PaginatedResult<T> _page<T>(List<T> items) => PaginatedResult<T>(
  items: items,
  totalItems: items.length,
  totalPages: 1,
  currentPage: 1,
  pageSize: 10,
);

Future<(Store<AppState>, GoRouter)> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1600, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final store = Store<AppState>(
    initialState: const AppState().copyWith(
      items: _page(const [
        ItemModel(uiName: 'Diamond Sword', id: 'i1'),
        ItemModel(uiName: 'Stone Pickaxe', id: 'i2'),
      ]),
      attributes: _page(const [AttributeModel(uiName: 'Max Mana', id: 'a1')]),
    ),
  );
  final router = GoRouter(
    initialLocation: '/fonts',
    routes: [
      ShellRoute(
        builder: (context, state, child) => CommandPaletteShortcuts(
          child: Scaffold(
            appBar: AppBar(title: const AppBarSearch()),
            body: child,
          ),
        ),
        routes: [
          GoRoute(path: '/fonts', builder: (_, _) => const Text('fonts page')),
          GoRoute(
            path: '/items',
            builder: (_, _) => const Text('items page'),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (_, _) => const Text('item detail'),
              ),
            ],
          ),
          GoRoute(
            path: '/attributes',
            builder: (_, _) => const Text('attributes page'),
          ),
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
  return (store, router);
}

Future<void> _open(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

Finder get _field => find.descendant(
  of: find.byType(AppBarSearch),
  matching: find.byType(TextField),
);

Finder get _chip => find.byKey(const Key('command-palette-mode-chip'));

Finder get _hints => find.byKey(const Key('command-palette-key-hints'));

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(_field, text);
  await tester.pumpAndSettle();
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

TextEditingController _controller(WidgetTester tester) =>
    tester.widget<TextField>(_field).controller!;

List<String> _titles(WidgetTester tester) => tester
    .widgetList<ListTile>(
      find.descendant(
        of: find.byType(CommandPanel),
        matching: find.byType(ListTile),
      ),
    )
    .map((tile) => (tile.title! as Text).data!)
    .toList();

bool _highlighted(WidgetTester tester, String title) => tester
    .widget<ListTile>(
      find.ancestor(of: find.text(title), matching: find.byType(ListTile)),
    )
    .selected;

bool _chipSays(String text) =>
    find.descendant(of: _chip, matching: find.text(text)).evaluate().isNotEmpty;

void main() {
  group('stepping in', () {
    testWidgets('Arrow Right on an item lists its tabs', (tester) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, '#sword');

      await _press(tester, LogicalKeyboardKey.arrowRight);

      expect(_titles(tester), [
        'General',
        'Meta',
        'Enchantments',
        'Lore',
        'Delete\u2026',
      ]);
      expect(_chipSays('Diamond Sword'), isTrue);
      expect(_controller(tester).text, isEmpty);
    });

    testWidgets('typing filters the tabs', (tester) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, '#sword');
      await _press(tester, LogicalKeyboardKey.arrowRight);

      await _type(tester, 'ench');

      expect(_titles(tester), ['Enchantments']);
    });

    testWidgets(
      'Arrow Right inside the text moves the cursor',
      (tester) async {
        await _pump(tester);
        await _open(tester);
        await _type(tester, '#sword');
        _controller(tester).selection = const TextSelection.collapsed(
          offset: 2,
        );
        await tester.pump();

        await _press(tester, LogicalKeyboardKey.arrowRight);

        expect(_controller(tester).selection.baseOffset, 3);
        expect(_titles(tester), contains('Diamond Sword'));
        expect(_chipSays('Diamond Sword'), isFalse);
      },
      // On web, EditableText hands arrow-key cursor movement to the native
      // <input> instead of its own Shortcuts/Actions (see Flutter's
      // DefaultTextEditingShortcuts._getDisablingShortcut, gated on kIsWeb).
      // `flutter test --platform chrome` has no such element - it only
      // synthesizes a Flutter-level key event - so the cursor never moves
      // and this assertion cannot be exercised there. The palette's own
      // logic (not stepping in while mid-text) is still covered by this
      // test on the VM target.
      skip: kIsWeb,
    );

    testWidgets('Arrow Right on an entry without sub-entries does nothing', (
      tester,
    ) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, ':items');
      final before = _titles(tester);

      await _press(tester, LogicalKeyboardKey.arrowRight);

      expect(_titles(tester), before);
      expect(_chipSays('Go to Items'), isFalse);
    });
  });

  group('stepping out', () {
    testWidgets('Arrow Left restores mode, query and highlight', (
      tester,
    ) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, '#');
      await _press(tester, LogicalKeyboardKey.arrowDown);
      expect(_highlighted(tester, 'Stone Pickaxe'), isTrue);
      await _press(tester, LogicalKeyboardKey.arrowRight);

      await _press(tester, LogicalKeyboardKey.arrowLeft);

      expect(_chipSays('Entities'), isTrue);
      expect(_titles(tester), contains('Diamond Sword'));
      expect(_highlighted(tester, 'Stone Pickaxe'), isTrue);
    });

    testWidgets('Arrow Left keeps the query that was typed', (tester) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, '#sword');
      await _press(tester, LogicalKeyboardKey.arrowRight);

      await _press(tester, LogicalKeyboardKey.arrowLeft);

      expect(_controller(tester).text, 'sword');
      expect(_titles(tester).first, 'Diamond Sword');
    });

    testWidgets('Backspace in the empty field steps out', (tester) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, '#sword');
      await _press(tester, LogicalKeyboardKey.arrowRight);

      await _press(tester, LogicalKeyboardKey.backspace);

      expect(_chipSays('Entities'), isTrue);
      expect(_controller(tester).text, 'sword');
    });

    testWidgets("the chip's delete action steps out", (tester) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, '#sword');
      await _press(tester, LogicalKeyboardKey.arrowRight);

      await tester.tap(find.byTooltip('Leave this mode'));
      await tester.pumpAndSettle();

      expect(_chipSays('Entities'), isTrue);
    });
  });

  testWidgets('choosing a tab opens the detail page on it', (tester) async {
    final (store, router) = await _pump(tester);
    await _open(tester);
    await _type(tester, '#sword');
    await _press(tester, LogicalKeyboardKey.arrowRight);
    await _type(tester, 'lore');

    await _press(tester, LogicalKeyboardKey.enter);

    expect(find.byType(CommandPanel), findsNothing);
    expect(store.state.selectedItem?.uiName, 'Diamond Sword');
    expect(router.state.uri.toString(), '/items/detail?tab=lore');
  });

  group('marker and hints', () {
    testWidgets('entities carry the marker, Go-to entries do not', (
      tester,
    ) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, '#');

      Finder markerOn(String title) => find.descendant(
        of: find.ancestor(
          of: find.text(title),
          matching: find.byType(ListTile),
        ),
        matching: find.byKey(const Key('command-palette-steps-in')),
      );
      expect(markerOn('Diamond Sword'), findsOneWidget);
      // Since Delete, attributes have something to step into as well.
      expect(markerOn('Max Mana'), findsOneWidget);
      expect(markerOn('Go to Sound'), findsNothing);
    });

    testWidgets('the step-in hint shows only where it applies', (tester) async {
      await _pump(tester);
      await _open(tester);
      Finder hint(String text) =>
          find.descendant(of: _hints, matching: find.text(text));

      expect(hint('More'), findsNothing);

      await _type(tester, '#');
      expect(hint('More'), findsOneWidget);

      await _press(tester, LogicalKeyboardKey.arrowRight);
      expect(hint('More'), findsNothing);
      expect(hint('Back'), findsOneWidget);
    });
  });
}
