import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/sound_decoder.dart';
import 'package:stelaris/feature/sound/playback/sound_file_player.dart';
import 'package:stelaris/feature/sound/playback/sound_playback_controller.dart';
import 'package:stelaris/feature/sound/playback/sound_player.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

SoundFileSource _source({double pitch = 1}) => SoundFileSource(
  name: 'vulpes:ui/click',
  volume: 1,
  pitch: pitch,
  attenuationDistance: 16,
  preload: false,
  type: 'file',
  weight: 1,
  assetId: 'a-1',
);

class _Loader implements SoundFileLoader {
  @override
  Future<SoundFile> load(String projectId, SoundFileSource source) async =>
      SoundFile(bytes: Uint8List(0), mimeType: 'audio/ogg');
}

class _Decoder implements SoundDecoder {
  /// Made on the first call, inside the fake time of the widget test; one
  /// made in setUp would complete outside of it and never arrive.
  Completer<SoundWaveform>? completer;

  @override
  Future<SoundWaveform> waveform(SoundFile file, {int buckets = 64}) =>
      (completer ??= Completer<SoundWaveform>()).future;
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
  }) => (playing = Completer<void>()).future;

  @override
  void stop() {
    final current = playing;
    playing = null;
    if (current != null && !current.isCompleted) current.complete();
  }
}

void main() {
  late _Decoder decoder;
  late _Player player;
  late SoundPlaybackController controller;

  setUp(() {
    decoder = _Decoder();
    player = _Player();
    controller = SoundPlaybackController(
      loader: _Loader(),
      player: player,
      decoder: decoder,
    );
  });

  tearDown(() => controller.dispose());

  Future<void> pumpPlayer(
    WidgetTester tester, {
    SoundFileSource? source,
    VoidCallback? onToggle,
  }) async {
    final played = source ?? _source();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: SoundFilePlayer(
              controller: controller,
              projectId: 'p1',
              source: played,
              onToggle:
                  onToggle ?? () => controller.toggle('p1', played).ignore(),
            ),
          ),
        ),
      ),
    );
  }

  const waveform = SoundWaveform(
    peaks: [0.2, 1, 0.5],
    duration: Duration(seconds: 62),
  );

  testWidgets('shows the length once the waveform is read', (tester) async {
    await pumpPlayer(tester);
    expect(find.text('–:––'), findsOneWidget);

    decoder.completer!.complete(waveform);
    // The waveform arrives a frame later, through the FutureBuilder.
    await tester.pump();
    await tester.pump();

    expect(find.text('1:02'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('a higher pitch plays the file in less time', (tester) async {
    await pumpPlayer(tester, source: _source(pitch: 2));

    decoder.completer!.complete(waveform);
    // The waveform arrives a frame later, through the FutureBuilder.
    await tester.pump();
    await tester.pump();

    expect(find.text('0:31'), findsOneWidget);
  });

  testWidgets('the play button toggles the file', (tester) async {
    var toggled = 0;
    await pumpPlayer(tester, onToggle: () => toggled++);

    await tester.tap(find.byIcon(Icons.play_arrow));

    expect(toggled, 1);
  });

  testWidgets('while it plays it shows the elapsed time and stops', (
    tester,
  ) async {
    await pumpPlayer(tester);
    decoder.completer!.complete(waveform);
    // The waveform arrives a frame later, through the FutureBuilder.
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    player.position = const Duration(seconds: 12);
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('0:12 / 1:02'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.text('1:02'), findsOneWidget);
  });

  testWidgets('while it plays only the waveform and the second repaint', (
    tester,
  ) async {
    await pumpPlayer(tester);
    decoder.completer!.complete(waveform);
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    final button = tester.widget(find.byType(IconButton));
    player.position = const Duration(milliseconds: 300);
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));

    // The frames moved the waveform, the rest of the player stayed built.
    expect(identical(tester.widget(find.byType(IconButton)), button), isTrue);
    expect(find.text('0:00 / 1:02'), findsOneWidget);

    player.position = const Duration(seconds: 1);
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text('0:01 / 1:02'), findsOneWidget);
  });

  testWidgets('another file starting leaves this player as it is', (
    tester,
  ) async {
    await pumpPlayer(tester);
    decoder.completer!.complete(waveform);
    await tester.pump();
    await tester.pump();
    final button = tester.widget(find.byType(IconButton));

    controller
        .toggle('p1', _source().copyWith(assetId: 'a-2', name: 'other'))
        .ignore();
    await tester.pump();

    expect(identical(tester.widget(find.byType(IconButton)), button), isTrue);
  });
}
