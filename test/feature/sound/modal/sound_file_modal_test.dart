import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/sound/modal/sound_file_modal.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('SoundFileModal', () {
    late List<SoundFileSource> saved;

    Future<void> pumpModal(
      WidgetTester tester, {
      SoundFileSource? source,
      SoundAssetPicker? pickSound,
    }) async {
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
              pickSound: pickSound,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('does not save without a name', (tester) async {
      await pumpModal(tester);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(saved, isEmpty);
      expect(find.text('Enter a Name'), findsOneWidget);
    });

    testWidgets('saves the trimmed name and the selected type', (tester) async {
      await pumpModal(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        '  block/ding  ',
      );
      await tester.tap(find.text('Event'));
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(saved, hasLength(1));
      expect(saved.single.name, 'block/ding');
      expect(saved.single.type, 'event');
    });

    testWidgets('suggests sound events for the name of an event', (
      tester,
    ) async {
      await pumpModal(tester);

      await tester.tap(find.text('Event'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'zombie hurt');
      await tester.pump();

      expect(find.text('minecraft:entity.zombie.hurt'), findsOneWidget);
    });

    testWidgets('a picked sound event becomes the name', (tester) async {
      await pumpModal(tester);

      await tester.tap(find.text('Event'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'zombie hurt');
      await tester.pump();
      await tester.tap(find.text('minecraft:entity.zombie.hurt'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(saved.single.name, 'minecraft:entity.zombie.hurt');
    });

    testWidgets('the name of a file suggests nothing', (tester) async {
      await pumpModal(tester);

      await tester.enterText(find.byType(TextFormField).first, 'zombie hurt');
      await tester.pump();

      expect(find.byType(MenuItemButton), findsNothing);
    });

    testWidgets('switching the type keeps the name', (tester) async {
      await pumpModal(tester);

      await tester.enterText(find.byType(TextFormField).first, 'block/ding');
      await tester.tap(find.text('Event'));
      await tester.pumpAndSettle();

      expect(find.text('block/ding'), findsOneWidget);
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

    testWidgets('clamps a stored pitch to the range the client plays', (
      tester,
    ) async {
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

    group('with uploaded sounds', () {
      const click = AssetModel(
        id: 'a-1',
        projectId: 'p1',
        key: 'vulpes:ui/click',
        kind: AssetKind.SOUND,
        displayName: 'Click',
        fileName: 'click.ogg',
        contentType: 'audio/ogg',
        size: 1,
        sha1: 'sha',
      );
      const linked = SoundFileSource(
        id: 's-1',
        name: 'vulpes:ui/click',
        volume: 1,
        pitch: 1,
        attenuationDistance: 16,
        preload: false,
        type: 'file',
        weight: 1,
        assetId: 'a-1',
      );

      /// Submits the modal: Add for a new file, Save for a linked one.
      Future<void> save(WidgetTester tester) async {
        final add = find.text('Add');
        await tester.tap(add.evaluate().isNotEmpty ? add : find.text('Save'));
        await tester.pumpAndSettle();
      }

      testWidgets('offers no choice without a picker', (tester) async {
        await pumpModal(tester);

        expect(find.text('Choose uploaded sound'), findsNothing);
      });

      testWidgets('the picker takes the place of the form and a chosen sound '
          'names the file and links it', (tester) async {
        String? preselected = 'unset';
        await pumpModal(
          tester,
          pickSound: (context, selectedKey, onPicked, onBack) {
            preselected = selectedKey;
            return TextButton(
              onPressed: () => onPicked(click),
              child: const Text('pick click'),
            );
          },
        );

        await tester.tap(find.text('Choose uploaded sound'));
        await tester.pumpAndSettle();
        expect(
          find.text('Choose uploaded sound'),
          findsNothing,
          reason: 'the picker replaces the form',
        );
        await tester.tap(find.text('pick click'));
        await tester.pumpAndSettle();
        await save(tester);

        expect(preselected, isNull);
        expect(saved.single.name, 'vulpes:ui/click');
        expect(saved.single.assetId, 'a-1');
        expect(saved.single.type, 'file');
      });

      testWidgets('a linked file keeps its sound', (tester) async {
        await pumpModal(
          tester,
          source: linked,
          pickSound: _noPicker,
        );

        expect(find.text('Linked to the uploaded sound'), findsOneWidget);
        await save(tester);

        expect(saved.single.assetId, 'a-1');
      });

      testWidgets('typing another name drops the link', (tester) async {
        await pumpModal(
          tester,
          source: linked,
          pickSound: _noPicker,
        );

        await tester.enterText(
          find.byType(TextFormField).first,
          'minecraft:block/ding',
        );
        await tester.pump();
        expect(find.text('Linked to the uploaded sound'), findsNothing);
        await save(tester);

        expect(saved.single.name, 'minecraft:block/ding');
        expect(saved.single.assetId, isNull);
      });

      testWidgets('the unlink button keeps the name', (tester) async {
        await pumpModal(
          tester,
          source: linked,
          pickSound: _noPicker,
        );

        await tester.tap(find.byTooltip('Unlink the uploaded sound'));
        await tester.pump();
        await save(tester);

        expect(saved.single.name, 'vulpes:ui/click');
        expect(saved.single.assetId, isNull);
      });

      testWidgets('an event is saved without a sound', (tester) async {
        await pumpModal(
          tester,
          source: linked,
          pickSound: _noPicker,
        );

        await tester.tap(find.text('Event'));
        await tester.pumpAndSettle();
        expect(find.text('Choose uploaded sound'), findsNothing);
        await save(tester);

        expect(saved.single.type, 'event');
        expect(saved.single.assetId, isNull);
      });

      testWidgets('the picker preselects the linked sound', (tester) async {
        String? preselected;
        await pumpModal(
          tester,
          source: linked,
          pickSound: (context, selectedKey, onPicked, onBack) {
            preselected = selectedKey;
            return const SizedBox();
          },
        );

        await tester.tap(find.text('Choose uploaded sound'));
        await tester.pumpAndSettle();

        expect(preselected, 'vulpes:ui/click');
      });

      testWidgets('going back from the picker keeps the form', (tester) async {
        await pumpModal(
          tester,
          source: linked,
          pickSound: (context, selectedKey, onPicked, onBack) => TextButton(
            onPressed: onBack,
            child: const Text('back'),
          ),
        );

        await tester.tap(find.text('Choose uploaded sound'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('back'));
        await tester.pumpAndSettle();

        expect(find.text('Linked to the uploaded sound'), findsOneWidget);
        await save(tester);

        expect(saved.single.name, 'vulpes:ui/click');
        expect(saved.single.assetId, 'a-1');
      });
    });
  });
}

/// A picker the test never opens.
Widget _noPicker(
  BuildContext context,
  String? selectedKey,
  ValueChanged<AssetModel> onPicked,
  VoidCallback onBack,
) => const SizedBox();
