import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/blockstate/block_picker.dart';
import 'package:stelaris/feature/blockstate/block_state_create_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  group('BlockStateCreateDialog', () {
    Future<void> open(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: Store<AppState>(initialState: const AppState()),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
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
  });
}
