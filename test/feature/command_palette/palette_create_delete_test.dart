import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/command_palette/command_palette.dart';
import 'package:stelaris/feature/command_palette/command_panel.dart';
import 'package:stelaris/feature/base/search/app_bar_search.dart';
import 'package:stelaris/feature/dialogs/model_create_dialog.dart';
import 'package:stelaris/feature/dialogs/model_delete_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_http_client_adapter.dart';

PaginatedResult<T> _page<T>(List<T> items) => PaginatedResult<T>(
  items: items,
  totalItems: items.length,
  totalPages: 1,
  currentPage: 1,
  pageSize: 10,
);

const ItemModel _sword = ItemModel(uiName: 'Diamond Sword', id: 'i1');

Future<(Store<AppState>, GoRouter)> _pump(
  WidgetTester tester, {
  String at = '/fonts',
  ItemModel? selectedItem,
}) async {
  tester.view.physicalSize = const Size(1600, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final store = Store<AppState>(
    initialState: const AppState().copyWith(
      selectedProject: const Project(
        id: 'p1',
        key: 'eldoria_rpg',
        displayName: 'Eldoria RPG',
      ),
      items: _page(const [_sword]),
      attributes: _page(const [AttributeModel(uiName: 'Max Mana', id: 'a1')]),
      selectedItem: selectedItem,
    ),
    // Adding and removing talk to the API; the tests that need an answer
    // fake one, the others only care what the palette does around it.
    globalErrorObserver: (_) => SwallowGlobalErrorObserver<AppState>(),
  );
  final router = GoRouter(
    initialLocation: at,
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

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(
    find.descendant(
      of: find.byType(AppBarSearch),
      matching: find.byType(TextField),
    ),
    text,
  );
  await tester.pumpAndSettle();
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

Future<void> _confirmDelete(WidgetTester tester, String name) async {
  await tester.enterText(
    find.descendant(
      of: find.byType(ModelDeleteDialog<ItemModel>),
      matching: find.byType(TextField),
    ),
    name,
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(ModelDeleteDialog<ItemModel>),
      matching: find.text('Delete'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('create', () {
    testWidgets('New item opens the item dialog; submitting shows Items', (
      tester,
    ) async {
      final (_, router) = await _pump(tester);
      await _open(tester);
      await _type(tester, '>new item');
      await _press(tester, LogicalKeyboardKey.enter);

      expect(find.byType(ModelCreateDialog), findsOneWidget);
      expect(
        find.text(
          lookupAppLocalizations(const Locale('en')).dialog_item_create,
        ),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'Ruby Sword');
      await tester.enterText(find.byType(TextFormField).at(1), 'ruby_sword');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(router.state.matchedLocation, '/items');
    });

    testWidgets('cancelling stays where the user was', (tester) async {
      final (_, router) = await _pump(tester);
      await _open(tester);
      await _type(tester, '>new item');
      await _press(tester, LogicalKeyboardKey.enter);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(ModelCreateDialog), findsNothing);
      expect(router.state.matchedLocation, '/fonts');
    });
  });

  group('delete from the drill-down', () {
    testWidgets('Delete opens the confirmation for that entity', (
      tester,
    ) async {
      final (store, _) = await _pump(tester);
      await _open(tester);
      await _type(tester, '#sword');
      await _press(tester, LogicalKeyboardKey.arrowRight);
      await _type(tester, 'delete');

      await _press(tester, LogicalKeyboardKey.enter);

      expect(find.byType(CommandPanel), findsNothing);
      expect(find.byType(ModelDeleteDialog<ItemModel>), findsOneWidget);
      expect(find.textContaining('Diamond Sword'), findsWidgets);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(store.state.items.items, contains(_sword));
    });

    testWidgets('an attribute can be stepped into for Delete', (tester) async {
      await _pump(tester);
      await _open(tester);
      await _type(tester, '#mana');

      await _press(tester, LogicalKeyboardKey.arrowRight);

      final titles = tester
          .widgetList<ListTile>(
            find.descendant(
              of: find.byType(CommandPanel),
              matching: find.byType(ListTile),
            ),
          )
          .map((tile) => (tile.title! as Text).data)
          .toList();
      expect(titles, ['Delete…']);
    });
  });

  testWidgets('Delete this item confirms, removes and returns to the list', (
    tester,
  ) async {
    ApiService().itemApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter.json(_sword.toJson());
    final (store, router) = await _pump(
      tester,
      at: '/items/detail',
      selectedItem: _sword,
    );
    await _open(tester);
    await _type(tester, '>delete this');
    await _press(tester, LogicalKeyboardKey.enter);
    expect(find.byType(ModelDeleteDialog<ItemModel>), findsOneWidget);

    await _confirmDelete(tester, 'Diamond Sword');

    expect(store.state.items.items, isNot(contains(_sword)));
    expect(router.state.matchedLocation, '/items');
  });
}
