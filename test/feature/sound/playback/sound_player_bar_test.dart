import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/sound_decoder.dart';
import 'package:stelaris/feature/sound/playback/sound_playback_controller.dart';
import 'package:stelaris/feature/sound/playback/sound_player.dart';
import 'package:stelaris/feature/sound/playback/sound_player_bar.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';
import 'package:stelaris_models/stelaris_models.dart';

SoundFileSource _source(String id, {int weight = 1}) => SoundFileSource(
  id: id,
  name: 'vulpes:step/$id',
  volume: 1,
  pitch: 1,
  attenuationDistance: 16,
  preload: false,
  type: 'file',
  weight: weight,
  assetId: 'asset-$id',
);

class _Loader implements SoundFileLoader {
  @override
  Future<SoundFile> load(String projectId, SoundFileSource source) async =>
      SoundFile(bytes: Uint8List(0), mimeType: 'audio/ogg');
}

class _Decoder implements SoundDecoder {
  @override
  Future<SoundWaveform> waveform(SoundFile file, {int buckets = 64}) async =>
      const SoundWaveform(peaks: [0.2, 1, 0.5], duration: Duration(seconds: 4));
}

class _Player implements SoundPlayer {
  Completer<void>? playing;
  final List<double> pitches = [];
  final List<Duration> seeks = [];
  final List<Duration> playedFrom = [];
  int pauses = 0;

  @override
  Duration position = Duration.zero;

  @override
  Future<void> play(
    SoundFile file, {
    required double volume,
    required double pitch,
    Duration from = Duration.zero,
  }) {
    playedFrom.add(from);
    return (playing = Completer<void>()).future;
  }

  @override
  void stop() {
    final current = playing;
    playing = null;
    if (current != null && !current.isCompleted) current.complete();
  }

  @override
  void pause() => pauses++;

  @override
  void resume() {}

  @override
  void seek(Duration position) => seeks.add(position);

  @override
  void adjust({required double volume, required double pitch}) =>
      pitches.add(pitch);
}

/// Always rolls [roll].
class _Random implements Random {
  _Random(this.roll);

  final int roll;

  @override
  int nextInt(int max) => roll;

  @override
  double nextDouble() => throw UnimplementedError();

  @override
  bool nextBool() => throw UnimplementedError();
}

void main() {
  late _Player player;
  late SoundPlaybackController controller;
  late List<SoundFileSource> applied;

  final a = _source('a');
  final b = _source('b', weight: 3);
  final c = _source('c');

  setUp(() {
    player = _Player();
    applied = [];
    controller = SoundPlaybackController(
      loader: _Loader(),
      player: player,
      decoder: _Decoder(),
    );
  });

  tearDown(() => controller.dispose());

  Future<void> pumpBar(WidgetTester tester, {Random? random}) async {
    tester.view.physicalSize = const Size(1400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: SoundPlayerBar(
              controller: controller,
              projectId: 'p1',
              sources: [a, b, c],
              titleOf: (source) => 'Step ${source.id}',
              onPlay: (source, {from = Duration.zero}) =>
                  controller.play('p1', source, from: from),
              onApply: (updated) async => applied.add(updated),
              random: random,
            ),
          ),
        ),
      ),
    );
  }

  /// Lets loads and waveforms arrive. Not pumpAndSettle: the bar ticks
  /// every frame while a file plays.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  /// Plays [source] as a card would, and lets it start.
  Future<void> start(WidgetTester tester, SoundFileSource source) async {
    controller.play('p1', source).ignore();
    await settle(tester);
  }

  testWidgets('stays hidden until a file is played', (tester) async {
    await pumpBar(tester);
    expect(find.byKey(const Key('sound_player_bar')), findsNothing);

    await start(tester, b);

    expect(find.byKey(const Key('sound_player_bar')), findsOneWidget);
    expect(find.text('Step b'), findsOneWidget);
    expect(find.text('vulpes:step/b'), findsOneWidget);
  });

  testWidgets('pauses and plays on', (tester) async {
    await pumpBar(tester);
    await start(tester, a);

    await tester.tap(find.byKey(const Key('sound_player_play_pause')));
    await tester.pump();
    expect(controller.status, SoundPlaybackStatus.paused);
    expect(player.pauses, 1);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    await tester.tap(find.byKey(const Key('sound_player_play_pause')));
    await tester.pump();
    expect(controller.status, SoundPlaybackStatus.playing);
    expect(find.byIcon(Icons.pause), findsOneWidget);
  });

  testWidgets('plays an ended file again', (tester) async {
    await pumpBar(tester);
    await start(tester, a);
    player.playing!.complete();
    await settle(tester);
    expect(controller.status, SoundPlaybackStatus.idle);

    await tester.tap(find.byKey(const Key('sound_player_play_pause')));
    await settle(tester);

    expect(controller.status, SoundPlaybackStatus.playing);
    expect(controller.current, a);
  });

  testWidgets('steps to the next and the previous file', (tester) async {
    await pumpBar(tester);
    await start(tester, b);

    await tester.tap(find.byKey(const Key('sound_player_next')));
    await settle(tester);
    expect(controller.current, c);

    await tester.tap(find.byKey(const Key('sound_player_previous')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('sound_player_previous')));
    await settle(tester);
    expect(controller.current, a);
  });

  testWidgets('has no previous before the first, no next after the last', (
    tester,
  ) async {
    await pumpBar(tester);
    await start(tester, a);

    IconButton button(String key) =>
        tester.widget<IconButton>(find.byKey(Key(key)));
    expect(button('sound_player_previous').onPressed, isNull);

    await start(tester, c);
    expect(button('sound_player_next').onPressed, isNull);
  });

  testWidgets('the dice plays a file picked by weight', (tester) async {
    // Rolls 0..4 over the weights 1, 3, 1: a 3 lands on b.
    await pumpBar(tester, random: _Random(3));
    await start(tester, a);

    await tester.tap(find.byKey(const Key('sound_player_random')));
    await settle(tester);

    expect(controller.current, b);
  });

  testWidgets('a tap in the waveform jumps there', (tester) async {
    await pumpBar(tester);
    await start(tester, a);

    final waveform = find.byKey(const Key('sound_player_waveform'));
    final box = tester.getRect(waveform);
    await tester.tapAt(Offset(box.left + box.width * 0.75, box.center.dy));
    await tester.pump();

    expect(player.seeks, [const Duration(seconds: 3)]);
  });

  testWidgets('a tap in the waveform of an ended file plays from there', (
    tester,
  ) async {
    await pumpBar(tester);
    await start(tester, a);
    player.playing!.complete();
    await settle(tester);

    final box = tester.getRect(find.byKey(const Key('sound_player_waveform')));
    await tester.tapAt(Offset(box.left + box.width / 2, box.center.dy));
    await settle(tester);

    expect(player.playedFrom.last, const Duration(seconds: 2));
  });

  testWidgets('the pitch is tried out live, then applied or reset', (
    tester,
  ) async {
    await pumpBar(tester);
    await start(tester, a);

    FilledButton applyButton() => tester.widget<FilledButton>(
      find.byKey(const Key('sound_player_apply')),
    );
    expect(applyButton().onPressed, isNull);

    final slider = find.descendant(
      of: find.byKey(const Key('sound_player_pitch')),
      matching: find.byType(Slider),
    );
    tester.widget<Slider>(slider).onChanged!(1.5000000001);
    await tester.pump();

    expect(controller.pitchOf(a), 1.5);
    expect(player.pitches, [1.5]);
    expect(find.text('1.50'), findsOneWidget);

    await tester.tap(find.byKey(const Key('sound_player_apply')));
    await tester.pump();
    expect(applied.single.pitch, 1.5);
    expect(applied.single.id, 'a');

    await tester.tap(find.byKey(const Key('sound_player_reset')));
    await tester.pump();
    expect(controller.hasPreview, isFalse);
    expect(controller.pitchOf(a), 1);
  });

  testWidgets('closing stops and hides the bar', (tester) async {
    await pumpBar(tester);
    await start(tester, a);

    await tester.tap(find.byKey(const Key('sound_player_close')));
    await settle(tester);

    expect(controller.current, isNull);
    expect(find.byKey(const Key('sound_player_bar')), findsNothing);
  });
}
