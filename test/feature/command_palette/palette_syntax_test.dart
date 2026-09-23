import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/attributes/attribute_edit_dialog.dart';
import 'package:stelaris/feature/base/button/cancel_button.dart';
import 'package:stelaris/feature/command_palette/command_palette.dart';
import 'package:stelaris/feature/command_palette/command_panel.dart';
import 'package:stelaris/feature/base/search/app_bar_search.dart';
import 'package:stelaris/feature/project/dialog/switch_project_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

PaginatedResult<T> _page<T>(List<T> items) => PaginatedResult<T>(
  items: items,
  totalItems: items.length,
  totalPages: 1,
  currentPage: 1,
  pageSize: 10,
);

const Project _eldoria = Project(
  id: 'p1',
  key: 'eldoria_rpg',
  displayName: 'Eldoria RPG',
);
const Project _demo = Project(id: 'p3', key: 'demo', displayName: 'Demo');

/// The palette shortcut around a small shell with a list, a detail page and
/// the attributes page, over a store with a few loaded entities.
Future<(Store<AppState>, GoRouter)> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1600, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final store = Store<AppState>(
    initialState: const AppState().copyWith(
      selectedProject: _eldoria,
      projects: const [_eldoria, _demo],
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
      GoRoute(path: '/projects', builder: (_, _) => const Text('projects')),
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

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(_field, text);
  await tester.pumpAndSettle();
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

/// Scrolls the palette's list until [finder] is built and on screen - help
/// is longer than the palette is tall.
Future<void> _scrollTo(
  WidgetTester tester,
  Finder finder, {
  double step = 80,
}) async {
  await tester.scrollUntilVisible(
    finder,
    step,
    // The list's own Scrollable, not the text field's.
    scrollable: find
        .descendant(
          of: find.descendant(
            of: find.byType(CommandPanel),
            matching: find.byType(ListView),
          ),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

String _fieldText(WidgetTester tester) =>
    tester.widget<TextField>(_field).controller!.text;

List<String> _titles(WidgetTester tester) => tester
    .widgetList<ListTile>(
      find.descendant(
        of: find.byType(CommandPanel),
        matching: find.byType(ListTile),
      ),
    )
    .map((tile) => (tile.title! as Text).data!)
    .toList();

void main() {
  group('entity jump', () {
    testWidgets('an item result selects the item and opens its detail page', (
      tester,
    ) async {
      final (store, router) = await _pump(tester);
      await _open(tester);

      await _type(tester, '#sword');
      await _press(tester, LogicalKeyboardKey.enter);

      expect(find.byType(CommandPanel), findsNothing);
      expect(router.state.matchedLocation, '/items/detail');
      expect(store.state.selectedItem?.uiName, 'Diamond Sword');
      expect(find.text('item detail'), findsOneWidget);
    });

    testWidgets('an attribute result opens its edit dialog', (tester) async {
      await _pump(tester);
      await _open(tester);

      await _type(tester, '#attribute ');
      await _type(tester, 'mana');
      await _press(tester, LogicalKeyboardKey.enter);

      expect(find.byType(CommandPanel), findsNothing);
      expect(find.byType(AttributeEditDialog), findsOneWidget);
    });
  });

  group('project switch', () {
    testWidgets('the current project is not offered', (tester) async {
      await _pump(tester);
      await _open(tester);

      await _type(tester, '@');

      expect(_titles(tester), ['Demo']);
    });

    testWidgets('confirming the dialog switches the project', (tester) async {
      final (store, _) = await _pump(tester);
      await _open(tester);

      await _type(tester, '@demo');
      await _press(tester, LogicalKeyboardKey.enter);
      expect(find.byType(SwitchProjectDialog), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(SwitchProjectDialog),
          matching: find.byType(FilledButton),
        ),
      );
      await tester.pumpAndSettle();

      expect(store.state.selectedProject?.id, _demo.id);
    });

    testWidgets('cancelling the dialog keeps the project', (tester) async {
      final (store, _) = await _pump(tester);
      await _open(tester);

      await _type(tester, '@demo');
      await _press(tester, LogicalKeyboardKey.enter);
      await tester.tap(find.byType(CancelButton));
      await tester.pumpAndSettle();

      expect(find.byType(SwitchProjectDialog), findsNothing);
      expect(store.state.selectedProject?.id, _eldoria.id);
    });
  });

  group('mode chip', () {
    testWidgets('#item followed by a space becomes an Items chip', (
      tester,
    ) async {
      await _pump(tester);
      await _open(tester);

      await _type(tester, '#item ');

      expect(
        find.descendant(of: _chip, matching: find.text('Items')),
        findsOneWidget,
      );
      expect(_fieldText(tester), isEmpty);
      expect(_titles(tester), ['Diamond Sword', 'Stone Pickaxe']);
    });

    testWidgets('the alias lists the same as the sigil', (tester) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, '#item sword');
      final List<String> viaSigil = _titles(tester);
      // The field keeps its chip between openings; two Esc clear it.
      await _press(tester, LogicalKeyboardKey.escape);
      await _press(tester, LogicalKeyboardKey.escape);

      await _open(tester);
      await _type(tester, 'item sword');

      expect(viaSigil, ['Diamond Sword']);
      expect(_titles(tester), viaSigil);
      expect(_fieldText(tester), 'sword');
    });

    testWidgets('Backspace on an empty field returns to the default mode', (
      tester,
    ) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, '/');
      expect(_chip, findsOneWidget);

      await _press(tester, LogicalKeyboardKey.backspace);

      expect(_chip, findsNothing);
      expect(_titles(tester), contains('Go to Items'));
    });

    testWidgets('Backspace drops the kind before the mode', (tester) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, '#item ');

      await _press(tester, LogicalKeyboardKey.backspace);

      expect(
        find.descendant(of: _chip, matching: find.text('Entities')),
        findsOneWidget,
      );
    });

    testWidgets("the chip's delete action returns to the default mode", (
      tester,
    ) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, '@');

      await tester.tap(find.byTooltip('Leave this mode'));
      await tester.pumpAndSettle();

      expect(_chip, findsNothing);
      expect(_titles(tester), contains('Go to Items'));
    });
  });

  group('help and fallback', () {
    testWidgets('choosing a help entry switches to that mode', (tester) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, '?');
      expect(_titles(tester).take(5), [
        '>  Commands',
        ':  Navigation',
        '#  Entities',
        '@  Projects',
        '/  Settings',
      ]);
      for (final heading in ['Syntax', 'Navigation', 'Keyboard']) {
        final Finder found = find.descendant(
          of: find.byType(CommandPanel),
          matching: find.text(heading),
        );
        await _scrollTo(tester, found);
        expect(found, findsOneWidget, reason: heading);
      }
      // Back up to the syntax section.
      await _scrollTo(tester, find.text('#  Entities'), step: -80);

      await tester.tap(find.text('#  Entities'));
      await tester.pumpAndSettle();

      expect(find.byType(CommandPanel), findsOneWidget);
      expect(
        find.descendant(of: _chip, matching: find.text('Entities')),
        findsOneWidget,
      );
      expect(_fieldText(tester), isEmpty);
      expect(
        find.text('Only entries that are already loaded are searched'),
        findsOneWidget,
      );
    });

    testWidgets('the entity fallback carries the text into entity mode', (
      tester,
    ) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, 'sword');
      expect(find.text('No matching commands'), findsOneWidget);

      await tester.tap(find.text('Search entities for “sword”'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: _chip, matching: find.text('Entities')),
        findsOneWidget,
      );
      expect(_fieldText(tester), 'sword');
      expect(_titles(tester).first, 'Diamond Sword');
    });
  });

  group('placeholder', () {
    String hint(WidgetTester tester) =>
        tester.widget<TextField>(_field).decoration!.hintText!;

    testWidgets('the default placeholder points to ?', (tester) async {
      await _pump(tester);
      await _open(tester);

      expect(hint(tester), contains('?'));
    });

    testWidgets('a kind says that loaded entries of it are searched', (
      tester,
    ) async {
      await _pump(tester);
      await _open(tester);

      await _type(tester, '#item ');

      expect(hint(tester), 'Search loaded items');
    });

    testWidgets('each mode has its own placeholder', (tester) async {
      await _pump(tester);
      await _open(tester);
      final hints = <String>{hint(tester)};

      for (final prefix in ['>', ':', '#', '@', '/', '?']) {
        await _type(tester, prefix);
        hints.add(hint(tester));
        await _press(tester, LogicalKeyboardKey.backspace);
      }

      expect(hints, hasLength(7));
    });
  });

  group('help sections', () {
    testWidgets('picking a page in help navigates there', (tester) async {
      final (_, router) = await _pump(tester);
      await _open(tester);
      await _type(tester, '?');
      await _scrollTo(tester, find.text('Go to Items'));

      await tester.tap(find.text('Go to Items'));
      await tester.pumpAndSettle();

      expect(find.byType(CommandPanel), findsNothing);
      expect(router.state.matchedLocation, '/items');
    });

    testWidgets('picking a keyboard entry leaves the palette open', (
      tester,
    ) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, '?esc');

      await _press(tester, LogicalKeyboardKey.enter);

      expect(find.byType(CommandPanel), findsOneWidget);
      expect(
        find.descendant(of: _chip, matching: find.text('Help')),
        findsOneWidget,
      );
      expect(_fieldText(tester), 'esc');
    });

    testWidgets(': lists only pages to go to', (tester) async {
      await _pump(tester);
      await _open(tester);

      await _type(tester, ':');

      expect(_titles(tester), [
        'Go to Attributes',
        'Go to Items',
        'Go to Notifications',
        'Go to Fonts',
        'Go to Sound',
        'Go to project list',
      ]);
    });
  });

  group('current page', () {
    Finder markOn(String title) => find.descendant(
      of: find.ancestor(of: find.text(title), matching: find.byType(ListTile)),
      matching: find.byKey(const Key('command-palette-current-page')),
    );

    testWidgets('the current page is listed and marked, others are not', (
      tester,
    ) async {
      await _pump(tester);
      await _open(tester);

      expect(markOn('Go to Fonts'), findsOneWidget);
      expect(markOn('Go to Items'), findsNothing);
      expect(
        find.descendant(
          of: markOn('Go to Fonts'),
          matching: find.text('Current page'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('from a detail page the marked entry leads back', (
      tester,
    ) async {
      final (_, router) = await _pump(tester);
      router.go('/items/detail');
      await tester.pumpAndSettle();
      await _open(tester);
      expect(markOn('Go to Items'), findsOneWidget);

      await _type(tester, ':items');
      await _press(tester, LogicalKeyboardKey.enter);

      expect(router.state.matchedLocation, '/items');
    });

    testWidgets('no Go-to fallback for the list the user is on', (
      tester,
    ) async {
      await _pump(tester);
      await _open(tester);

      await _type(tester, '#font ');

      expect(_titles(tester), isEmpty);
      expect(
        find.text('Only entries that are already loaded are searched'),
        findsOneWidget,
      );
    });
  });
}
