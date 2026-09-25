import 'package:async_redux/async_redux.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/command_palette/command.dart';
import 'package:stelaris/feature/command_palette/command_palette.dart';
import 'package:stelaris/feature/command_palette/command_panel.dart';
import 'package:stelaris/feature/base/search/app_bar_search.dart';
import 'package:stelaris/feature/command_palette/command_registry.dart';
import 'package:stelaris/feature/command_palette/commands.dart';
import 'package:stelaris/feature/settings/settings_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';

final List<String> _ran = [];

StelarisCommand _command(String title, {CommandGroup? group}) {
  return StelarisCommand(
    id: title,
    title: (_) => title,
    group: group ?? CommandGroup.interface,
    icon: Icons.circle,
    run: (_) async => _ran.add(title),
  );
}

/// A page with the palette shortcut installed and a text field to focus.
Future<void> _pump(WidgetTester tester, CommandRegistry registry) async {
  tester.view.physicalSize = const Size(1600, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/items',
    routes: [
      GoRoute(
        path: '/items',
        builder: (context, state) => CommandPaletteShortcuts(
          registry: registry,
          child: Scaffold(
            appBar: AppBar(title: const AppBarSearch()),
            body: const TextField(key: Key('page-field')),
          ),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: Store<AppState>(initialState: const AppState()),
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pressCtrlK(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

Finder get _palette => find.byType(CommandPanel);

Finder get _paletteField => find.descendant(
  of: find.byType(AppBarSearch),
  matching: find.byType(TextField),
);

bool _highlighted(WidgetTester tester, String title) {
  final tile = tester.widget<ListTile>(
    find.ancestor(of: find.text(title), matching: find.byType(ListTile)),
  );
  return tile.selected;
}

void main() {
  setUp(_ran.clear);

  final registry = CommandRegistry([
    _command('Alpha'),
    _command('Bravo'),
    _command('Charlie'),
    _command('Toggle dark mode'),
  ]);

  group('search', () {
    testWidgets('lists every command, grouped, on an empty query', (
      tester,
    ) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);

      expect(_palette, findsOneWidget);
      for (final title in ['Alpha', 'Bravo', 'Charlie', 'Toggle dark mode']) {
        expect(find.text(title), findsOneWidget);
      }
      expect(find.text('Interface'), findsOneWidget);
    });

    testWidgets('typing narrows the list to matching commands', (tester) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);

      await tester.enterText(_paletteField, 'dark');
      await tester.pumpAndSettle();

      expect(find.text('Toggle dark mode'), findsOneWidget);
      expect(find.text('Alpha'), findsNothing);
      expect(find.text('Charlie'), findsNothing);

      // Let the list filter's debounce run out: async_redux's Debounce waits
      // on a Future.delayed that nothing can cancel.
      await tester.pump(const Duration(milliseconds: 350));
    });

    testWidgets('an unmatched query shows the empty-result text', (
      tester,
    ) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);

      await tester.enterText(_paletteField, 'zzzz');
      await tester.pumpAndSettle();

      expect(find.text('No matching commands'), findsOneWidget);
      // No command is listed: the filter entry first, then the fallbacks
      // that search the same text as an entity or a project.
      expect(find.text('Alpha'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(CommandPanel),
          matching: find.byType(ListTile),
        ),
        findsNWidgets(3),
      );

      // Let the list filter's debounce run out: async_redux's Debounce waits
      // on a Future.delayed that nothing can cancel.
      await tester.pump(const Duration(milliseconds: 350));
    });
  });

  group('keyboard', () {
    testWidgets('Down, Down, Enter runs the third entry', (tester) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);

      await _press(tester, LogicalKeyboardKey.arrowDown);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      await _press(tester, LogicalKeyboardKey.enter);

      expect(_ran, ['Charlie']);
      expect(_palette, findsNothing);
    });

    testWidgets('the first entry starts highlighted and Up wraps to the last', (
      tester,
    ) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);
      expect(_highlighted(tester, 'Alpha'), isTrue);

      await _press(tester, LogicalKeyboardKey.arrowUp);

      expect(_highlighted(tester, 'Toggle dark mode'), isTrue);
      expect(_highlighted(tester, 'Alpha'), isFalse);
    });

    testWidgets('Down on the last entry wraps to the first', (tester) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);

      await _press(tester, LogicalKeyboardKey.arrowUp);
      await _press(tester, LogicalKeyboardKey.arrowDown);

      expect(_highlighted(tester, 'Alpha'), isTrue);
    });

    testWidgets('wrapping keeps the highlighted entry in view in a list '
        'longer than the palette', (tester) async {
      final long = CommandRegistry([
        for (int i = 0; i < 30; i++)
          _command('Command ${i.toString().padLeft(2, '0')}'),
      ]);
      await _pump(tester, long);
      await _pressCtrlK(tester);

      // Up from the first entry wraps to the last, far below the fold.
      await _press(tester, LogicalKeyboardKey.arrowUp);
      expect(_highlighted(tester, 'Command 29'), isTrue);
      expect(find.text('Command 29').hitTestable(), findsOneWidget);

      // Down from the last wraps back to the first, far above it.
      await _press(tester, LogicalKeyboardKey.arrowDown);
      expect(_highlighted(tester, 'Command 00'), isTrue);
      expect(find.text('Command 00').hitTestable(), findsOneWidget);
    });

    testWidgets('changing the query resets the highlight', (tester) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);
      await _press(tester, LogicalKeyboardKey.arrowDown);

      await tester.enterText(_paletteField, 'a');
      await tester.pumpAndSettle();

      final first = tester.widgetList<ListTile>(find.byType(ListTile)).first;
      expect(first.selected, isTrue);
    });

    testWidgets('Escape closes without running anything', (tester) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);

      await _press(tester, LogicalKeyboardKey.escape);

      expect(_palette, findsNothing);
      expect(_ran, isEmpty);
    });

    testWidgets('clicking outside closes without running anything', (
      tester,
    ) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(_palette, findsNothing);
      expect(_ran, isEmpty);
    });

    testWidgets('the shortcut closes an open palette', (tester) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);
      expect(_palette, findsOneWidget);

      await _pressCtrlK(tester);

      expect(_palette, findsNothing);
      expect(_ran, isEmpty);
    });

    testWidgets('Cmd+K opens it as well', (tester) async {
      await _pump(tester, registry);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pumpAndSettle();

      expect(_palette, findsOneWidget);
    });
  });

  group('running', () {
    testWidgets('clicking a command runs it', (tester) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);

      await tester.tap(find.text('Bravo'));
      await tester.pumpAndSettle();

      expect(_ran, ['Bravo']);
      expect(_palette, findsNothing);
    });

    testWidgets('"Open settings" leaves only the settings dialog', (
      tester,
    ) async {
      await _pump(tester, CommandRegistry(pocCommands()));
      await _pressCtrlK(tester);

      // The prefix keeps the filter entry away, so Enter runs the command.
      await tester.enterText(_paletteField, '>open settings');
      await tester.pumpAndSettle();
      await _press(tester, LogicalKeyboardKey.enter);

      expect(_palette, findsNothing);
      expect(find.byType(SettingsDialog), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });
  });

  group('highlight and key hints', () {
    testWidgets('pointing at an entry moves the one highlight', (tester) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);
      expect(_highlighted(tester, 'Alpha'), isTrue);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Charlie')));
      await tester.pumpAndSettle();

      expect(_highlighted(tester, 'Charlie'), isTrue);
      expect(_highlighted(tester, 'Alpha'), isFalse);
      final charlie = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('Charlie'),
          matching: find.byType(ListTile),
        ),
      );
      expect(charlie.hoverColor, Colors.transparent);
    });

    testWidgets('the key hints are shown under the list', (tester) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);
      final hints = find.byKey(const Key('command-palette-key-hints'));

      for (final query in ['', '>', '#', '@', '/', '?', 'zzzz']) {
        await tester.enterText(_paletteField, query);
        await tester.pumpAndSettle();
        expect(hints, findsOneWidget, reason: query);
        await tester.enterText(_paletteField, '');
        await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
        await tester.pumpAndSettle();
      }
      for (final text in ['Navigate', 'Run', 'Close', 'Help']) {
        expect(
          find.descendant(of: hints, matching: find.text(text)),
          findsOneWidget,
        );
      }

      // Let the list filter's debounce run out: async_redux's Debounce waits
      // on a Future.delayed that nothing can cancel.
      await tester.pump(const Duration(milliseconds: 350));
    });

    testWidgets('the last entry of a long list ends above the key hints', (
      tester,
    ) async {
      final long = CommandRegistry([
        for (int i = 0; i < 30; i++)
          _command('Command ${i.toString().padLeft(2, '0')}'),
      ]);
      await _pump(tester, long);
      await _pressCtrlK(tester);

      await _press(tester, LogicalKeyboardKey.arrowUp);

      final Rect last = tester.getRect(
        find.ancestor(
          of: find.text('Command 29'),
          matching: find.byType(ListTile),
        ),
      );
      final Rect hints = tester.getRect(
        find.byKey(const Key('command-palette-key-hints')),
      );
      expect(last.bottom, lessThanOrEqualTo(hints.top));
    });
  });

  testWidgets('the search icon lines up with the text beside it and with '
      'the entries below', (tester) async {
    await _pump(tester, registry);
    await _pressCtrlK(tester);

    final Rect icon = tester.getRect(
      find.byKey(const Key('command-palette-search-icon')),
    );
    final Rect text = tester.getRect(
      find.descendant(of: _paletteField, matching: find.byType(EditableText)),
    );
    final Finder firstTile = find
        .descendant(
          of: find.byType(CommandPanel),
          matching: find.byType(ListTile),
        )
        .first;
    final Rect tileIcon = tester.getRect(
      find.descendant(of: firstTile, matching: find.byType(Icon)).first,
    );

    expect(icon.center.dy, moreOrLessEquals(text.center.dy, epsilon: 1));
    // Centres, not edges: the search icon sits in a 32px button, the rows'
    // icons are bare 24px icons.
    expect(icon.center.dx, moreOrLessEquals(tileIcon.center.dx, epsilon: 1));
  });

  testWidgets('the mode chip starts on the column of the dropdown icons', (
    tester,
  ) async {
    await _pump(tester, registry);
    await _pressCtrlK(tester);

    await tester.enterText(_paletteField, '>');
    await tester.pumpAndSettle();

    final Rect chip = tester.getRect(
      find.byKey(const Key('command-palette-mode-chip')),
    );
    final Rect tileIcon = tester.getRect(
      find
          .descendant(
            of: find
                .descendant(
                  of: find.byType(CommandPanel),
                  matching: find.byType(ListTile),
                )
                .first,
            matching: find.byType(Icon),
          )
          .first,
    );
    expect(chip.left, moreOrLessEquals(tileIcon.left, epsilon: 1));
  });

  testWidgets('the mode chip is a pill like the field', (tester) async {
    await _pump(tester, registry);
    await _pressCtrlK(tester);

    await tester.enterText(_paletteField, '>');
    await tester.pumpAndSettle();

    final InputChip chip = tester.widget<InputChip>(
      find.byKey(const Key('command-palette-mode-chip')),
    );
    expect(chip.shape, isA<StadiumBorder>());
  });

  group('rebuilds', () {
    Element rowOf(WidgetTester tester, String title) => tester.element(
      find.ancestor(of: find.text(title), matching: find.byType(ListTile)),
    );

    testWidgets('typing keeps the rows that still match', (tester) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);
      final Element before = rowOf(tester, 'Charlie');

      await tester.enterText(_paletteField, 'c');
      await tester.pumpAndSettle();

      expect(identical(rowOf(tester, 'Charlie'), before), isTrue);

      // Let the list filter's debounce run out: async_redux's Debounce waits
      // on a Future.delayed that nothing can cancel.
      await tester.pump(const Duration(milliseconds: 350));
    });

    testWidgets('moving the highlight leaves the search field alone', (
      tester,
    ) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);
      final Widget field = tester.widget(_paletteField);

      await _press(tester, LogicalKeyboardKey.arrowDown);

      expect(_highlighted(tester, 'Bravo'), isTrue);
      expect(identical(tester.widget(_paletteField), field), isTrue);
    });

    testWidgets('moving the highlight leaves uninvolved rows alone', (
      tester,
    ) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);
      ListTile tile(String title) => tester.widget<ListTile>(
        find.ancestor(of: find.text(title), matching: find.byType(ListTile)),
      );
      final ListTile charlie = tile('Charlie');
      final ListTile alpha = tile('Alpha');

      await _press(tester, LogicalKeyboardKey.arrowDown);

      // Alpha lost the highlight, Bravo gained it; Charlie was not rebuilt.
      expect(identical(tile('Charlie'), charlie), isTrue);
      expect(identical(tile('Alpha'), alpha), isFalse);
    });

    testWidgets('hovering leaves the search field alone', (tester) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);
      final Widget field = tester.widget(_paletteField);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);

      await mouse.moveTo(tester.getCenter(find.text('Charlie')));
      await tester.pumpAndSettle();

      expect(_highlighted(tester, 'Charlie'), isTrue);
      expect(identical(tester.widget(_paletteField), field), isTrue);
    });

    testWidgets('a resize keeps the highlight', (tester) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);
      await _press(tester, LogicalKeyboardKey.arrowDown);

      tester.view.physicalSize = const Size(1400, 1000);
      addTearDown(tester.view.reset);
      await tester.pumpAndSettle();

      expect(_highlighted(tester, 'Bravo'), isTrue);
    });
  });

  testWidgets('rows paint their highlight on the clipped list, not on the '
      'dropdown, so it cannot bleed over the key hints', (tester) async {
    await _pump(tester, registry);
    await _pressCtrlK(tester);

    final Material inkSurface = tester.widget<Material>(
      find
          .ancestor(
            of: find
                .descendant(
                  of: find.byType(CommandPanel),
                  matching: find.byType(ListTile),
                )
                .first,
            matching: find.byType(Material),
          )
          .first,
    );

    expect(inkSurface.key, const Key('command-palette-list-surface'));
    expect(inkSurface.clipBehavior, isNot(Clip.none));
  });
}
