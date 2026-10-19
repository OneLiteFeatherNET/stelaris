@Tags(['web'])
library;

import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/command_palette/command_panel.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/palette.dart';

Finder get _hints => find.byKey(const Key('command-palette-key-hints'));

TextEditingController _controller(WidgetTester tester) =>
    tester.widget<TextField>(paletteField).controller!;

bool _chipSays(String text) => find
    .descendant(of: modeChip, matching: find.text(text))
    .evaluate()
    .isNotEmpty;

Future<(Store<AppState>, GoRouter)> _pump(WidgetTester tester) async {
  final store = Store<AppState>(
    initialState: const AppState().copyWith(
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
  );
  return (store, router);
}

void main() {
  group('stepping in', () {
    testWidgets('Arrow Right on an item lists its tabs', (tester) async {
      await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '#sword');

      await pressKey(tester, LogicalKeyboardKey.arrowRight);

      expect(paletteTitles(tester), [
        'Components',
        'Enchantments',
        'Lore',
        'Delete\u2026',
      ]);
      expect(_chipSays('Diamond Sword'), isTrue);
      expect(_controller(tester).text, isEmpty);
    });

    testWidgets('typing filters the tabs', (tester) async {
      await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '#sword');
      await pressKey(tester, LogicalKeyboardKey.arrowRight);

      await typeInPalette(tester, 'ench');

      expect(paletteTitles(tester), ['Enchantments']);
    });

    testWidgets(
      'Arrow Right inside the text moves the cursor',
      (tester) async {
        await _pump(tester);
        await pressCtrlK(tester);
        await typeInPalette(tester, '#sword');
        _controller(tester).selection = const TextSelection.collapsed(
          offset: 2,
        );
        await tester.pump();

        await pressKey(tester, LogicalKeyboardKey.arrowRight);

        expect(_controller(tester).selection.baseOffset, 3);
        expect(paletteTitles(tester), contains('Diamond Sword'));
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
      await pressCtrlK(tester);
      await typeInPalette(tester, ':items');
      final before = paletteTitles(tester);

      await pressKey(tester, LogicalKeyboardKey.arrowRight);

      expect(paletteTitles(tester), before);
      expect(_chipSays('Go to Items'), isFalse);
    });
  });

  group('stepping out', () {
    testWidgets('Arrow Left restores mode, query and highlight', (
      tester,
    ) async {
      await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '#');
      await pressKey(tester, LogicalKeyboardKey.arrowDown);
      expect(isHighlighted(tester, 'Stone Pickaxe'), isTrue);
      await pressKey(tester, LogicalKeyboardKey.arrowRight);

      await pressKey(tester, LogicalKeyboardKey.arrowLeft);

      expect(_chipSays('Entities'), isTrue);
      expect(paletteTitles(tester), contains('Diamond Sword'));
      expect(isHighlighted(tester, 'Stone Pickaxe'), isTrue);
    });

    testWidgets('Arrow Left keeps the query that was typed', (tester) async {
      await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '#sword');
      await pressKey(tester, LogicalKeyboardKey.arrowRight);

      await pressKey(tester, LogicalKeyboardKey.arrowLeft);

      expect(_controller(tester).text, 'sword');
      expect(paletteTitles(tester).first, 'Diamond Sword');
    });

    testWidgets('Backspace in the empty field steps out', (tester) async {
      await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '#sword');
      await pressKey(tester, LogicalKeyboardKey.arrowRight);

      await pressKey(tester, LogicalKeyboardKey.backspace);

      expect(_chipSays('Entities'), isTrue);
      expect(_controller(tester).text, 'sword');
    });

    testWidgets("the chip's delete action steps out", (tester) async {
      await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '#sword');
      await pressKey(tester, LogicalKeyboardKey.arrowRight);

      await tester.tap(find.byTooltip('Leave this mode'));
      await tester.pumpAndSettle();

      expect(_chipSays('Entities'), isTrue);
    });
  });

  testWidgets('choosing a tab opens the detail page on it', (tester) async {
    final (store, router) = await _pump(tester);
    await pressCtrlK(tester);
    await typeInPalette(tester, '#sword');
    await pressKey(tester, LogicalKeyboardKey.arrowRight);
    await typeInPalette(tester, 'lore');

    await pressKey(tester, LogicalKeyboardKey.enter);

    expect(find.byType(CommandPanel), findsNothing);
    expect(store.state.selectedItem?.uiName, 'Diamond Sword');
    expect(router.state.uri.toString(), '/items/detail?tab=lore');
  });

  group('marker and hints', () {
    testWidgets('entities carry the marker, Go-to entries do not', (
      tester,
    ) async {
      await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '#');

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
      await pressCtrlK(tester);
      Finder hint(String text) =>
          find.descendant(of: _hints, matching: find.text(text));

      expect(hint('More'), findsNothing);

      await typeInPalette(tester, '#');
      expect(hint('More'), findsOneWidget);

      await pressKey(tester, LogicalKeyboardKey.arrowRight);
      expect(hint('More'), findsNothing);
      expect(hint('Back'), findsOneWidget);
    });
  });
}
