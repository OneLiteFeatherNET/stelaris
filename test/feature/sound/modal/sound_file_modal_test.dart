import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/sound/modal/sound_file_modal.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('SoundFileModal', () {
    late List<SoundFileSource> saved;

    Future<void> pumpModal(WidgetTester tester, {SoundFileSource? source}) async {
      saved = [];
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SoundFileModal(
              create: source == null,
              initialData: source,
              onSave: saved.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('does not save without a name', (tester) async {
      await pumpModal(tester);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(saved, isEmpty);
      expect(find.text('Enter a Name'), findsOneWidget);
    });

    testWidgets('saves the trimmed name and the selected type', (tester) async {
      await pumpModal(tester);

      await tester.enterText(find.byType(TextFormField).first, '  block/ding  ');
      await tester.tap(find.text('Event'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(saved, hasLength(1));
      expect(saved.single.name, 'block/ding');
      expect(saved.single.type, 'event');
    });

    testWidgets('keeps the values of an existing file', (tester) async {
      const source = SoundFileSource(
        id: 'file-1',
        name: 'ambient/cave',
        volume: 0.5,
        pitch: 0.8,
        weight: 3,
        attenuationDistance: 24,
        preload: true,
        type: 'file',
      );
      await pumpModal(tester, source: source);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(saved.single, source);
      expect(find.text('Stream'), findsNothing);
    });

    testWidgets('clamps a stored pitch to the range the client plays', (tester) async {
      const source = SoundFileSource(
        id: 'file-2',
        name: 'ambient/low',
        volume: 1,
        pitch: 0.2,
        weight: 1,
        attenuationDistance: 16,
        preload: false,
        type: 'file',
      );
      await pumpModal(tester, source: source);

      final pitchSlider = tester.widget<Slider>(find.byType(Slider).last);
      expect(pitchSlider.min, minPitch);
      expect(pitchSlider.max, maxPitch);
      expect(pitchSlider.value, minPitch);
      expect(find.text('0.50'), findsOneWidget);
    });
  });
}
