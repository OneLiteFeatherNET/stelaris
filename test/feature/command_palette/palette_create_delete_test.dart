@Tags(['web'])
library;

import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/command_palette/command_panel.dart';
import 'package:stelaris/feature/dialogs/model_create_dialog.dart';
import 'package:stelaris/feature/dialogs/model_delete_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/palette.dart';
import '../../support/pump_until.dart';

const ItemModel _sword = ItemModel(uiName: 'Diamond Sword', id: 'i1');

Future<void> _confirmDelete(
  WidgetTester tester,
  Store<AppState> store,
  String name,
) async {
  await tester.enterText(
    find.descendant(
      of: find.byType(ModelDeleteDialog<ItemModel>),
      matching: find.byType(TextField),
    ),
    name,
  );
  await tester.pumpAndSettle();
  // Tapping "Delete" fires ItemRemoveAction and closes the dialog without
  // waiting for it. Its Dio call, even through the fake adapter, uses real
  // Timer-guarded internals that never resolve inside flutter_test's
  // fake-async zone on web unless the whole chain - the tap that starts it
  // included - runs in a real one; waiting for it afterwards is too late.
  await tester.runAsync(() async {
    await tester.tap(
      find.descendant(
        of: find.byType(ModelDeleteDialog<ItemModel>),
        matching: find.text('Delete'),
      ),
    );
    await store.waitActionType(ItemRemoveAction, completeImmediately: true);
  });
  await tester.pumpAndSettle();
}

Future<(Store<AppState>, GoRouter)> _pump(
  WidgetTester tester, {
  String at = '/fonts',
  ItemModel? selectedItem,
}) async {
  final store = Store<AppState>(
    initialState: const AppState().copyWith(
      selectedProject: const Project(
        id: 'p1',
        key: 'eldoria_rpg',
        displayName: 'Eldoria RPG',
      ),
      items: pageOf(const [_sword]),
      attributes: pageOf(const [AttributeModel(uiName: 'Max Mana', id: 'a1')]),
      selectedItem: selectedItem,
    ),
    // Adding and removing talk to the API; the tests that need an answer
    // fake one, the others only care what the palette does around it.
    globalErrorObserver: (_) => SwallowGlobalErrorObserver<AppState>(),
  );
  final router = await pumpPaletteShell(
    tester,
    store,
    pages: palettePages(),
    at: at,
  );
  return (store, router);
}

void main() {
  group('create', () {
    testWidgets('New item opens the item dialog; submitting shows Items', (
      tester,
    ) async {
      // Submitting dispatches ItemAddAction, which talks to the API; the
      // dialog waits for it and closes once the item exists, so it is
      // stubbed to answer like the backend.
      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(
            const ItemModel(
              uiName: 'Ruby Sword',
              key: 'ruby_sword',
              id: 'i2',
            ).toJson(),
          );
      final (_, router) = await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '>new item');
      await pressKey(tester, LogicalKeyboardKey.enter);

      expect(find.byType(ModelCreateDialog), findsOneWidget);
      expect(
        find.text(
          lookupAppLocalizations(const Locale('en')).dialog_item_create,
        ),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'Ruby Sword');
      await tester.enterText(find.byType(TextFormField).at(1), 'ruby_sword');
      // Tapping "Create" fires ItemAddAction, which talks to the (fake)
      // API through Dio's real Timer-guarded internals. Those don't
      // resolve inside flutter_test's fake-async zone on web, so this runs
      // outside it, in a real async zone, the same way the app would.
      await pumpUntil(
        tester,
        action: () => tester.tap(find.text('Create')),
        done: () => find.byType(ModelCreateDialog).evaluate().isEmpty,
      );

      expect(router.state.matchedLocation, '/items');
    });

    testWidgets('cancelling stays where the user was', (tester) async {
      final (_, router) = await _pump(tester);
      await pressCtrlK(tester);
      await typeInPalette(tester, '>new item');
      await pressKey(tester, LogicalKeyboardKey.enter);

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
      await pressCtrlK(tester);
      await typeInPalette(tester, '#sword');
      await pressKey(tester, LogicalKeyboardKey.arrowRight);
      await typeInPalette(tester, 'delete');

      await pressKey(tester, LogicalKeyboardKey.enter);

      expect(find.byType(CommandPanel), findsNothing);
      expect(find.byType(ModelDeleteDialog<ItemModel>), findsOneWidget);
      expect(find.textContaining('Diamond Sword'), findsWidgets);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(store.state.items.items, contains(_sword));
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
    await pressCtrlK(tester);
    await typeInPalette(tester, '>delete this');
    await pressKey(tester, LogicalKeyboardKey.enter);
    expect(find.byType(ModelDeleteDialog<ItemModel>), findsOneWidget);

    await _confirmDelete(tester, store, 'Diamond Sword');

    expect(store.state.items.items, isNot(contains(_sword)));
    expect(router.state.matchedLocation, '/items');
  });
}
