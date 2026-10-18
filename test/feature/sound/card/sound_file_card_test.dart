import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/sound/card/sound_file_card.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('SoundFileCard', () {
    Future<void> pumpCard(
      WidgetTester tester, {
      double width = 400,
      VoidCallback? onEdit,
      VoidCallback? onDelete,
    }) {
      return tester.pumpWidget(
        StoreProvider<AppState>(
          store: Store<AppState>(initialState: const AppState()),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: SoundFileCard(
                    source: const SoundFileSource(
                      name: 'step',
                      volume: 0.5,
                      pitch: 1,
                      attenuationDistance: 16,
                      preload: false,
                      type: 'event',
                      weight: 1,
                    ),
                    onEdit: onEdit ?? () {},
                    onDelete: onDelete ?? () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows the name once with the type, volume and pitch', (
      tester,
    ) async {
      await pumpCard(tester);

      expect(find.text('step'), findsOneWidget);
      expect(find.text('Event · Volume 0.5 · Pitch 1.0'), findsOneWidget);
    });

    testWidgets('a tap on the card edits the file', (tester) async {
      var edited = 0;
      await pumpCard(tester, onEdit: () => edited++);

      await tester.tap(find.text('step'));

      expect(edited, 1);
    });

    testWidgets('offers only a delete button', (tester) async {
      var deleted = 0;
      await pumpCard(tester, onDelete: () => deleted++);

      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
      await tester.tap(find.byIcon(Icons.delete_forever));

      expect(deleted, 1);
    });

    testWidgets('a tap on the narrow card edits the file', (tester) async {
      var edited = 0;
      await pumpCard(tester, width: 120, onEdit: () => edited++);

      expect(find.text('step'), findsNothing);
      await tester.tap(find.byIcon(Icons.folder));

      expect(edited, 1);
    });
  });
}
