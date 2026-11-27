import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/sound_decoder.dart';
import 'package:stelaris/feature/sound/playback/sound_file_play_button.dart';
import 'package:stelaris/feature/sound/playback/sound_playback_controller.dart';
import 'package:stelaris/feature/sound/playback/sound_player.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';
import 'package:stelaris_models/stelaris_models.dart';

SoundFileSource _source(String name) => SoundFileSource(
  name: name,
  volume: 1,
  pitch: 1,
  attenuationDistance: 16,
  preload: false,
  type: 'file',
  weight: 1,
  assetId: 'asset-$name',
);

class _Loader implements SoundFileLoader {
  @override
  Future<SoundFile> load(String projectId, SoundFileSource source) async =>
      SoundFile(bytes: Uint8List(0), mimeType: 'audio/ogg');
}

class _Decoder implements SoundDecoder {
  @override
  Future<SoundWaveform> waveform(SoundFile file, {int buckets = 64}) async =>
      const SoundWaveform(peaks: [1], duration: Duration(seconds: 1));
}

class _Player implements SoundPlayer {
  Completer<void>? playing;

  @override
  Duration position = Duration.zero;

  @override
  Future<void> play(
    SoundFile file, {
    required double volume,
    required double pitch,
    Duration from = Duration.zero,
  }) => (playing = Completer<void>()).future;

  @override
  void stop() {
    final current = playing;
    playing = null;
    if (current != null && !current.isCompleted) current.complete();
  }

  @override
  void pause() {}

  @override
  void resume() {}

  @override
  void seek(Duration position) {}

  @override
  void adjust({required double volume, required double pitch}) {}
}

void main() {
  late SoundPlaybackController controller;

  setUp(() {
    controller = SoundPlaybackController(
      loader: _Loader(),
      player: _Player(),
      decoder: _Decoder(),
    );
  });

  tearDown(() => controller.dispose());

  Future<void> pumpButton(WidgetTester tester, SoundFileSource source) =>
      tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SoundFilePlayButton(
              controller: controller,
              source: source,
              onPressed: () => controller.toggle('p1', source).ignore(),
            ),
          ),
        ),
      );

  testWidgets('plays, pauses and plays on', (tester) async {
    final source = _source('a');
    await pumpButton(tester, source);
    expect(find.byTooltip('Play'), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await tester.pump();
    await tester.pump();
    expect(find.byTooltip('Pause'), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(controller.status, SoundPlaybackStatus.paused);
    expect(find.byTooltip('Play'), findsOneWidget);
  });

  testWidgets('another file starting leaves the button as it is', (
    tester,
  ) async {
    final source = _source('a');
    await pumpButton(tester, source);
    final before = tester.widget(find.byType(IconButton));

    controller.play('p1', _source('b')).ignore();
    await tester.pump();
    await tester.pump();

    expect(identical(tester.widget(find.byType(IconButton)), before), isTrue);
  });
}
