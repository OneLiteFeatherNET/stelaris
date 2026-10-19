@Tags(['web'])
library;

import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/button/cancel_button.dart';
import 'package:stelaris/feature/command_palette/command_panel.dart';
import 'package:stelaris/feature/project/dialog/switch_project_dialog.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/palette.dart';

const Project _eldoria = Project(
  id: 'p1',
  key: 'eldoria_rpg',
  displayName: 'Eldoria RPG',
);
const Project _demo = Project(id: 'p3', key: 'demo', displayName: 'Demo');

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
    tester.widget<TextField>(paletteField).controller!.text;

/// The palette over a few loaded entities, on a list page.
Future<(Store<AppState>, GoRouter)> _pump(WidgetTester tester) async {
  final store = Store<AppState>(
    initialState: const AppState().copyWith(
      selectedProject: _eldoria,
      projects: const [_eldoria, _demo],
      items: pageOf(const [
        ItemModel(uiName: 'Diamond Sword', id: 'i1'),
        ItemModel(uiName: 'Stone Pickaxe', id: 'i2'),
      ]),
      attributes: pageOf(const [AttributeModel(uiName: 'Max Mana', id: 'a1')]),
    ),
  );
  final router = await pumpPaletteShell(
    tester,
    store,
    pages: palettePages(),
    at: '/fonts',
    outside: [
      GoRoute(path: '/projects', builder: (_, _) => const Text('projects')),
    ],
  );
  return (store, router);
}

void main() {
  group('entity jump', () {
    testWidgets('an item result selects the item and opens its detail page', (
      tester,
    ) async {
      final (store, router) = await _pump(tester);
      await pressCtrlK(tester);

      await typeInPalette(tester, '#sword');
      await pressKey(tester, LogicalKeyboardKey.enter);

      expect(find.byType(CommandPanel), findsNothing);
      expect(router.state.matchedLocation, '/items/detail');
      expect(store.state.selectedItem?.uiName, 'Diamond Sword');
      expect(find.text('item detail'), findsOneWidget);
    });

    testWidgets('an attribute result opens its detail page', (tester) async {
      final (store, router) = await _pump(tester);
      await pressCtrlK(tester);

      await typeInPalette(tester, '#attribute ');
      await typeInPalette(tester, 'mana');
      await pressKey(tester, LogicalKeyboardKey.enter);

      expect(find.byType(CommandPanel), findsNothing);
      expect(router.state.matchedLocation, '/projects/p1/attributes/a1');
      expect(store.state.selectedAttribute?.uiName, 'Max Mana');
      expect(find.text('attribute detail'), findsOneWidget);
    });
  });

  group('project switch', () {

    testWidgets('confirming the dialog switches the project', (tester) async {
      final (store, _) = await _pump(tester);
      await pressCtrlK(tester);

      await typeInPalette(tester, '@demo');
      await pressKey(tester, LogicalKeyboardKey.enter);
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
      await pressCtrlK(tester);

      await typeInPalette(tester, '@demo');
      await pressKey(tester, LogicalKeyboardKey.enter);
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
      await pressCtrlK(tester);

      await typeInPalette(tester, '#item ');

      expect(
        find.descendant(of: modeChip, matching: find.text('Items')),
        findsOneWidget,
      );
      expect(_fieldText(tester), isEmpty);
      expect(paletteTitles(tester), ['Diamond Sword', 'Stone Pickaxe']);
    });

    testWidgets('the alias lists the same as the sigil', (tester) async {
      await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '#item sword');
      final List<String> viaSigil = paletteTitles(tester);
      // The field keeps its chip between openings; two Esc clear it.
      await pressKey(tester, LogicalKeyboardKey.escape);
      await pressKey(tester, LogicalKeyboardKey.escape);

      await pressCtrlK(tester);
      await typeInPalette(tester, 'item sword');

      expect(viaSigil, ['Diamond Sword']);
      expect(paletteTitles(tester), viaSigil);
      expect(_fieldText(tester), 'sword');
    });

    testWidgets('Backspace on an empty field returns to the default mode', (
      tester,
    ) async {
      await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '/');
      expect(modeChip, findsOneWidget);

      await pressKey(tester, LogicalKeyboardKey.backspace);

      expect(modeChip, findsNothing);
      expect(paletteTitles(tester), contains('Go to Items'));
    });

    testWidgets('Backspace drops the kind before the mode', (tester) async {
      await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '#item ');

      await pressKey(tester, LogicalKeyboardKey.backspace);

      expect(
        find.descendant(of: modeChip, matching: find.text('Entities')),
        findsOneWidget,
      );
    });

    testWidgets("the chip's delete action returns to the default mode", (
      tester,
    ) async {
      await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '@');

      await tester.tap(find.byTooltip('Leave this mode'));
      await tester.pumpAndSettle();

      expect(modeChip, findsNothing);
      expect(paletteTitles(tester), contains('Go to Items'));
    });
  });

  group('help and fallback', () {
    testWidgets('choosing a help entry switches to that mode', (tester) async {
      await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '?');
      expect(paletteTitles(tester).take(5), [
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
        find.descendant(of: modeChip, matching: find.text('Entities')),
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
      await pressCtrlK(tester);
      await typeInPalette(tester, 'sword');
      expect(find.text('No matching commands'), findsOneWidget);

      await tester.tap(find.text('Search entities for “sword”'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: modeChip, matching: find.text('Entities')),
        findsOneWidget,
      );
      expect(_fieldText(tester), 'sword');
      expect(paletteTitles(tester).first, 'Diamond Sword');
    });
  });

  group('placeholder', () {
    String hint(WidgetTester tester) =>
        tester.widget<TextField>(paletteField).decoration!.hintText!;

    testWidgets('the default placeholder points to ?', (tester) async {
      await _pump(tester);
      await pressCtrlK(tester);

      expect(hint(tester), contains('?'));
    });

    testWidgets('a kind says that loaded entries of it are searched', (
      tester,
    ) async {
      await _pump(tester);
      await pressCtrlK(tester);

      await typeInPalette(tester, '#item ');

      expect(hint(tester), 'Search loaded items');
    });

    testWidgets('each mode has its own placeholder', (tester) async {
      await _pump(tester);
      await pressCtrlK(tester);
      final hints = <String>{hint(tester)};

      for (final prefix in ['>', ':', '#', '@', '/', '?']) {
        await typeInPalette(tester, prefix);
        hints.add(hint(tester));
        await pressKey(tester, LogicalKeyboardKey.backspace);
      }

      expect(hints, hasLength(7));
    });
  });

  group('help sections', () {
    testWidgets('picking a page in help navigates there', (tester) async {
      final (_, router) = await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '?');
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
      await pressCtrlK(tester);
      await typeInPalette(tester, '?esc');

      await pressKey(tester, LogicalKeyboardKey.enter);

      expect(find.byType(CommandPanel), findsOneWidget);
      expect(
        find.descendant(of: modeChip, matching: find.text('Help')),
        findsOneWidget,
      );
      expect(_fieldText(tester), 'esc');
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
      await pressCtrlK(tester);

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
      await pressCtrlK(tester);
      expect(markOn('Go to Items'), findsOneWidget);

      await typeInPalette(tester, ':items');
      await pressKey(tester, LogicalKeyboardKey.enter);

      expect(router.state.matchedLocation, '/items');
    });
  });
}
