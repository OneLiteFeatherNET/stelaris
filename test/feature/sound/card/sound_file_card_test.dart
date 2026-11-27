import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/sound/card/sound_file_card.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';
import 'package:stelaris_models/stelaris_models.dart';

SoundFileSource _source({
  String type = 'file',
  String? assetId,
  double pitch = 1,
}) => SoundFileSource(
  name: 'vulpes:ui/click',
  volume: 0.5,
  pitch: pitch,
  attenuationDistance: 16,
  preload: false,
  type: type,
  weight: 1,
  assetId: assetId,
);

void main() {
  group('SoundFileCard', () {
    Future<void> pumpCard(
      WidgetTester tester, {
      SoundFileSource? source,
      Widget? playButton,
      String? assetName,
      Duration? length,
      bool highlighted = false,
      bool loading = false,
      double? height,
      VoidCallback? onEdit,
      VoidCallback? onDelete,
    }) {
      return tester.pumpWidget(
        StoreProvider<AppState>(
          store: Store<AppState>(initialState: const AppState()),
          child: MaterialApp(
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: height,
                  child: SoundFileCard(
                    source: source ?? _source(),
                    playButton: playButton,
                    assetName: assetName,
                    length: length,
                    highlighted: highlighted,
                    loading: loading,
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

    testWidgets('shows the name and a footer of type, volume, pitch and '
        'weight', (tester) async {
      await pumpCard(tester);

      expect(find.text('vulpes:ui/click'), findsOneWidget);
      expect(
        find.text('File · Volume 0.5 · Pitch 1.0 · Weight 1'),
        findsOneWidget,
      );
    });

    testWidgets('adds the length as it plays at the pitch of the file', (
      tester,
    ) async {
      await pumpCard(
        tester,
        source: _source(assetId: 'a-1', pitch: 2),
        length: const Duration(seconds: 62),
      );

      expect(
        find.text('File · Volume 0.5 · Pitch 2.0 · Weight 1 · 0:31'),
        findsOneWidget,
      );
    });

    testWidgets('a highlighted card is outlined', (tester) async {
      await pumpCard(tester, highlighted: true);

      final shape = tester.widget<Card>(find.byType(Card)).shape;
      expect(shape, isA<RoundedRectangleBorder>());
      expect((shape! as RoundedRectangleBorder).side.width, greaterThan(0));
    });

    testWidgets('a linked file is titled with its asset, the key below', (
      tester,
    ) async {
      await pumpCard(
        tester,
        source: _source(assetId: 'a-1'),
        assetName: 'Click',
      );

      final title = tester.getTopLeft(find.text('Click')).dy;
      final key = tester.getTopLeft(find.text('vulpes:ui/click')).dy;
      expect(key, greaterThan(title));
    });

    testWidgets('while loading shows only a progress indicator', (
      tester,
    ) async {
      await pumpCard(
        tester,
        source: _source(assetId: 'a-1'),
        playButton: const Text('player'),
        loading: true,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('vulpes:ui/click'), findsNothing);
      expect(find.text('player'), findsNothing);
    });

    testWidgets('a tap on the card edits the file', (tester) async {
      var edited = 0;
      await pumpCard(tester, onEdit: () => edited++);

      await tester.tap(find.text('vulpes:ui/click'));

      expect(edited, 1);
    });

    testWidgets('the delete button deletes the file', (tester) async {
      var deleted = 0;
      var edited = 0;
      await pumpCard(tester, onDelete: () => deleted++, onEdit: () => edited++);

      await tester.tap(find.byIcon(Icons.delete_forever));

      expect(deleted, 1);
      expect(edited, 0);
    });

    testWidgets('shows the play button of an uploaded file', (tester) async {
      await pumpCard(
        tester,
        source: _source(assetId: 'a-1'),
        playButton: const Text('player'),
      );

      expect(find.text('player'), findsOneWidget);
    });

    testWidgets('fits its height with a play button and a length', (
      tester,
    ) async {
      await pumpCard(
        tester,
        source: _source(assetId: 'a-1'),
        assetName: 'Click',
        height: SoundFileCard.height,
        length: const Duration(seconds: 3),
        playButton: IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(Icons.play_arrow),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a file without upload says it has no audio', (tester) async {
      await pumpCard(tester);

      expect(
        find.byTooltip('No uploaded sound, e.g. a vanilla one'),
        findsOneWidget,
      );
    });

    testWidgets('an event says it plays another event', (tester) async {
      await pumpCard(tester, source: _source(type: 'event'));

      expect(find.byTooltip('Plays another sound event'), findsOneWidget);
      expect(
        find.text('Event · Volume 0.5 · Pitch 1.0 · Weight 1'),
        findsOneWidget,
      );
    });
  });
}
