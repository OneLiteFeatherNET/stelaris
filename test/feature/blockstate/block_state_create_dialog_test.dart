import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/actions/block_state_actions.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/blockstate/block_picker.dart';
import 'package:stelaris/feature/blockstate/block_state_create_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/held_http_client_adapter.dart';

/// Answers the dialog's load of the blockstates with one page of [items].
void _respond(List<Map<String, Object?>> items) {
  (ApiService().blockStateApi as BaseApi<BlockStateModel>)
      .apiClient
      .dio
      .httpClientAdapter = FakeHttpClientAdapter.json({
    'items': items,
    'totalItems': items.length,
    'totalPages': 1,
    'currentPage': 1,
    'pageSize': 10,
  });
}

void main() {
  group('BlockStateCreateDialog', () {
    late Store<AppState> store;

    Future<void> open(
      WidgetTester tester, {
      List<Map<String, Object?>> stored = const [],
    }) async {
      _respond(stored);
      store = Store<AppState>(initialState: const AppState());
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => openBlockStateCreateDialog(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('can only be added with a name and a block', (tester) async {
      await open(tester);

      FilledButton add() =>
          tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Add'));
      expect(add().onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'Footprints');
      await tester.pump();
      expect(add().onPressed, isNull);
    });

    testWidgets('picks the block in the same dialog, not one above it', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(find.text('Choose a block'));
      await tester.pumpAndSettle();

      expect(find.byType(BlockPicker), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('the back arrow returns to the name', (tester) async {
      await open(tester);
      await tester.enterText(find.byType(TextField), 'Footprints');
      await tester.tap(find.text('Choose a block'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(BlockPicker), findsNothing);
      expect(find.text('Footprints'), findsOneWidget);
    });

    testWidgets('counts the contexts of the block from the backend, not only '
        'from the loaded list', (tester) async {
      await open(
        tester,
        stored: [
          {'id': 'b1', 'uiName': 'Seats', 'key': 'minecraft:oak_stairs'},
          {'id': 'b2', 'uiName': 'Roof', 'key': 'minecraft:oak_stairs'},
        ],
      );
      await tester.tap(find.text('Choose a block'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byType(BlockPicker),
          matching: find.byType(TextField),
        ),
        'oak_stairs',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('minecraft:oak_stairs').first);
      await tester.pumpAndSettle();

      expect(find.textContaining('already has 2 contexts'), findsOneWidget);
    });
  
    testWidgets('is busy while a blockstate is added', (tester) async {
      await open(tester);
      final backend = HeldHttpClientAdapter();
      (ApiService().blockStateApi as BaseApi<BlockStateModel>)
              .apiClient
              .dio
              .httpClientAdapter =
          backend;
      bool busy() => tester.widget<FormDialog>(find.byType(FormDialog)).busy;

      store.dispatch(
        BlockStateAddAction(
          const BlockStateModel(uiName: 'Footprints', key: 'minecraft:stone'),
        ),
      );
      // The dialog hears of the store through a stream, a frame later.
      await tester.pump();
      await tester.pump();
      expect(busy(), isTrue);

      backend.release({
        'id': 'b1',
        'uiName': 'Footprints',
        'key': 'minecraft:stone',
      });
      await tester.pumpAndSettle();
      expect(busy(), isFalse);
    });
});
}
