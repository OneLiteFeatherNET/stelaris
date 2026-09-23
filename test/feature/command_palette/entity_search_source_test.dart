import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/search/app_bar_search.dart';
import 'package:stelaris/feature/command_palette/command_palette.dart';
import 'package:stelaris/feature/command_palette/command_panel.dart';
import 'package:stelaris/feature/command_palette/entity_search_source.dart';
import 'package:stelaris/feature/command_palette/palette_mode.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// A search service whose answers the test hands out one by one.
class _FakeSource implements EntitySearchSource {
  final List<EntitySearchRequest> requests = [];
  final List<Completer<List<EntityHit>>> answers = [];

  @override
  Future<List<EntityHit>> search(EntitySearchRequest request) {
    requests.add(request);
    final answer = Completer<List<EntityHit>>();
    answers.add(answer);
    return answer.future;
  }
}

const ItemModel _sword = ItemModel(uiName: 'Diamond Sword', id: 'i1');

Future<(Store<AppState>, GoRouter)> _pump(
  WidgetTester tester,
  EntitySearchSource? source,
) async {
  tester.view.physicalSize = const Size(1600, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final store = Store<AppState>(
    initialState: const AppState().copyWith(
      selectedProject: const Project(id: 'p1', key: 'p', displayName: 'P'),
      items: const PaginatedResult<ItemModel>(
        items: [_sword],
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
          entitySearch: source,
          child: Scaffold(
            appBar: AppBar(title: const AppBarSearch()),
            body: child,
          ),
        ),
        routes: [
          GoRoute(
            path: '/items',
            builder: (_, _) => const Text('Item List'),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (_, _) => const Text('Item Detail'),
              ),
            ],
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
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
  return (store, router);
}

Finder get _field => find.descendant(
  of: find.byType(AppBarSearch),
  matching: find.byType(TextField),
);

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(_field, text);
  await tester.pump();
}

/// Past the source's debounce.
Future<void> _waitForSource(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 300));

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
  testWidgets('an unloaded hit arrives, and choosing it opens it', (
    tester,
  ) async {
    final source = _FakeSource();
    final (store, router) = await _pump(tester, source);

    await _type(tester, '#blade');
    expect(find.textContaining('Searching…'), findsOneWidget);
    await _waitForSource(tester);

    expect(source.requests, [
      const EntitySearchRequest(query: 'blade', limit: 15, projectId: 'p1'),
    ]);
    source.answers.single.complete([
      const EntityHit(
        EntityKind.item,
        ItemModel(uiName: 'Obsidian Blade', id: 'x9'),
      ),
    ]);
    await tester.pumpAndSettle();

    expect(_titles(tester).first, 'Obsidian Blade');
    expect(find.textContaining('Searching…'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(store.state.selectedItem?.uiName, 'Obsidian Blade');
    expect(router.state.matchedLocation, '/items/detail');
  });

  testWidgets('a hit that is already listed is listed once', (tester) async {
    final source = _FakeSource();
    await _pump(tester, source);

    await _type(tester, '#sword');
    await _waitForSource(tester);
    source.answers.single.complete([const EntityHit(EntityKind.item, _sword)]);
    await tester.pumpAndSettle();

    expect(
      _titles(tester).where((title) => title == 'Diamond Sword'),
      hasLength(1),
    );
  });

  testWidgets('an answer to an older query is ignored', (tester) async {
    final source = _FakeSource();
    await _pump(tester, source);

    await _type(tester, '#bl');
    await _waitForSource(tester);
    // The chip holds the mode now; typing goes on after it.
    await _type(tester, 'blade');
    await _waitForSource(tester);
    expect(source.requests.map((request) => request.query), ['bl', 'blade']);

    source.answers[1].complete([
      const EntityHit(
        EntityKind.item,
        ItemModel(uiName: 'Alpha Blade', id: 'a'),
      ),
    ]);
    await tester.pumpAndSettle();
    source.answers[0].complete([
      const EntityHit(EntityKind.item, ItemModel(uiName: 'Blue Lamp', id: 'b')),
    ]);
    await tester.pumpAndSettle();

    expect(_titles(tester), contains('Alpha Blade'));
    expect(_titles(tester), isNot(contains('Blue Lamp')));
  });

  testWidgets('fast typing asks once, after the pause', (tester) async {
    final source = _FakeSource();
    await _pump(tester, source);

    // After the first keystroke the chip holds the mode.
    for (final text in ['#b', 'bl', 'bla', 'blad']) {
      await _type(tester, text);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _waitForSource(tester);

    expect(source.requests.map((request) => request.query), ['blad']);
  });

  testWidgets('a failing source keeps the loaded matches and says so', (
    tester,
  ) async {
    final source = _FakeSource();
    await _pump(tester, source);

    await _type(tester, '#sword');
    await _waitForSource(tester);
    source.answers.single.completeError(Exception('down'));
    await tester.pumpAndSettle();

    expect(_titles(tester), contains('Diamond Sword'));
    expect(find.textContaining('unavailable'), findsOneWidget);
  });

  testWidgets('a hit of the wrong model type for its kind is dropped', (
    tester,
  ) async {
    final source = _FakeSource();
    await _pump(tester, source);

    await _type(tester, '#blade');
    await _waitForSource(tester);
    source.answers.single.complete([
      const EntityHit(
        EntityKind.font,
        ItemModel(uiName: 'Mislabelled Blade', id: 'm'),
      ),
    ]);
    await tester.pumpAndSettle();

    expect(_titles(tester), isNot(contains('Mislabelled Blade')));
  });

  testWidgets('without a source only loaded entries are searched', (
    tester,
  ) async {
    await _pump(tester, null);

    await _type(tester, '#blade');
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Only entries that are already loaded'),
      findsOneWidget,
    );
  });

  testWidgets('a highlight the user moved stays put when hits arrive', (
    tester,
  ) async {
    final source = _FakeSource();
    await _pump(tester, source);

    await _type(tester, '#sword');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    final ListTile before = tester
        .widgetList<ListTile>(
          find.descendant(
            of: find.byType(CommandPanel),
            matching: find.byType(ListTile),
          ),
        )
        .firstWhere((tile) => tile.selected);
    final String moved = (before.title! as Text).data!;
    await _waitForSource(tester);
    source.answers.single.complete([
      const EntityHit(
        EntityKind.item,
        ItemModel(uiName: 'Sword of Ash', id: 'z'),
      ),
    ]);
    await tester.pumpAndSettle();

    final ListTile after = tester
        .widgetList<ListTile>(
          find.descendant(
            of: find.byType(CommandPanel),
            matching: find.byType(ListTile),
          ),
        )
        .firstWhere((tile) => tile.selected);
    expect((after.title! as Text).data, moved);
  });
}
