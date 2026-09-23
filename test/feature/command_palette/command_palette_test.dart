import 'package:async_redux/async_redux.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/command_palette/command.dart';
import 'package:stelaris/feature/command_palette/command_palette.dart';
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
  final router = GoRouter(
    initialLocation: '/items',
    routes: [
      GoRoute(
        path: '/items',
        builder: (context, state) => CommandPaletteShortcuts(
          registry: registry,
          child: const Scaffold(body: TextField(key: Key('page-field'))),
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

Finder get _palette => find.byType(CommandPalette);

Finder get _paletteField =>
    find.descendant(of: _palette, matching: find.byType(TextField));

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
    });

    testWidgets('an unmatched query shows the empty-result text', (
      tester,
    ) async {
      await _pump(tester, registry);
      await _pressCtrlK(tester);

      await tester.enterText(_paletteField, 'zzzz');
      await tester.pumpAndSettle();

      expect(find.text('No matching commands'), findsOneWidget);
      // Since the query syntax: no command is listed, only the fallbacks
      // that search the same text as an entity or a project.
      expect(find.text('Alpha'), findsNothing);
      expect(find.byType(ListTile), findsNWidgets(2));
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

      await tester.enterText(_paletteField, 'open settings');
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

  testWidgets('the search icon and the text line up with each other and '
      'with the entries below', (tester) async {
    await _pump(tester, registry);
    await _pressCtrlK(tester);

    final Rect icon = tester.getRect(
      find.byKey(const Key('command-palette-search-icon')),
    );
    final Rect text = tester.getRect(
      find.descendant(of: _paletteField, matching: find.byType(EditableText)),
    );
    final Finder firstTile = find.byType(ListTile).first;
    final Rect tileIcon = tester.getRect(
      find.descendant(of: firstTile, matching: find.byType(Icon)).first,
    );
    final Rect tileTitle = tester.getRect(
      find.descendant(of: firstTile, matching: find.text('Alpha')),
    );

    expect(icon.center.dy, moreOrLessEquals(text.center.dy, epsilon: 1));
    expect(icon.left, moreOrLessEquals(tileIcon.left, epsilon: 1));
    expect(text.left, moreOrLessEquals(tileTitle.left, epsilon: 1));
  });
}
