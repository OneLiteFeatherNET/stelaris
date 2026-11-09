import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/sound_decoder.dart';
import 'package:stelaris/feature/sound/playback/sound_playback_controller.dart';
import 'package:stelaris/feature/sound/playback/sound_player.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';
import 'package:stelaris_models/stelaris_models.dart';

SoundFileSource _source(String name, {double volume = 1, double pitch = 1}) =>
    SoundFileSource(
      name: name,
      volume: volume,
      pitch: pitch,
      attenuationDistance: 16,
      preload: false,
      type: 'file',
      weight: 1,
    );

final SoundFile _file = SoundFile(
  bytes: Uint8List.fromList([1, 2, 3]),
  mimeType: 'audio/ogg',
);

class _FakeLoader implements SoundFileLoader {
  final Map<String, Completer<SoundFile>> pending = {};
  final List<(String, String)> requests = [];

  @override
  Future<SoundFile> load(String projectId, SoundFileSource source) {
    requests.add((projectId, source.name));
    return (pending[source.name] = Completer<SoundFile>()).future;
  }
}

class _FakePlayer implements SoundPlayer {
  Completer<void>? playing;
  final List<(SoundFile, double, double)> played = [];
  int stops = 0;

  @override
  Future<void> play(
    SoundFile file, {
    required double volume,
    required double pitch,
  }) {
    played.add((file, volume, pitch));
    return (playing = Completer<void>()).future;
  }

  @override
  void stop() {
    stops++;
    final current = playing;
    playing = null;
    if (current != null && !current.isCompleted) current.complete();
  }

  void finish() => playing?.complete();

  @override
  Duration position = Duration.zero;
}

class _FakeDecoder implements SoundDecoder {
  final List<SoundFile> decoded = [];

  @override
  Future<SoundWaveform> waveform(SoundFile file, {int buckets = 64}) async {
    decoded.add(file);
    return const SoundWaveform(peaks: [0.5, 1], duration: Duration(seconds: 2));
  }
}

void main() {
  late _FakeLoader loader;
  late _FakePlayer player;
  late _FakeDecoder decoder;
  late SoundPlaybackController controller;

  setUp(() {
    loader = _FakeLoader();
    player = _FakePlayer();
    decoder = _FakeDecoder();
    controller = SoundPlaybackController(
      loader: loader,
      player: player,
      decoder: decoder,
    );
  });

  tearDown(() => controller.dispose());

  test(
    'loads the file of the source, then plays it with volume and pitch',
    () async {
      final source = _source('vulpes:ui/click', volume: 0.5, pitch: 1.5);

      final done = controller.toggle('p1', source);
      expect(controller.statusOf(source), SoundPlaybackStatus.loading);
      expect(loader.requests, [('p1', 'vulpes:ui/click')]);

      loader.pending['vulpes:ui/click']!.complete(_file);
      await pumpEventQueue();
      expect(controller.statusOf(source), SoundPlaybackStatus.playing);
      expect(player.played, [(_file, 0.5, 1.5)]);

      player.finish();
      await done;
      expect(controller.statusOf(source), SoundPlaybackStatus.idle);
    },
  );

  test('a second toggle of the playing source stops it', () async {
    final source = _source('a');
    final done = controller.toggle('p1', source);
    loader.pending['a']!.complete(_file);
    await pumpEventQueue();

    await controller.toggle('p1', source);
    await done;

    expect(player.stops, 1);
    expect(controller.statusOf(source), SoundPlaybackStatus.idle);
  });

  test('starting another source stops the one that plays', () async {
    final a = _source('a');
    final b = _source('b');
    final doneA = controller.toggle('p1', a);
    loader.pending['a']!.complete(_file);
    await pumpEventQueue();

    final doneB = controller.toggle('p1', b);
    await doneA;
    expect(controller.statusOf(a), SoundPlaybackStatus.idle);
    expect(controller.statusOf(b), SoundPlaybackStatus.loading);

    loader.pending['b']!.complete(_file);
    await pumpEventQueue();
    expect(controller.statusOf(b), SoundPlaybackStatus.playing);
    player.finish();
    await doneB;
  });

  test('a load that arrives after a stop does not play', () async {
    final source = _source('a');
    final done = controller.toggle('p1', source);

    controller.stop();
    loader.pending['a']!.complete(_file);
    await done;

    expect(player.played, isEmpty);
    expect(controller.statusOf(source), SoundPlaybackStatus.idle);
  });

  test('a failed load is rethrown and resets the status', () async {
    final source = _source('a');
    final done = controller.toggle('p1', source);

    loader.pending['a']!.completeError(SoundFileUnavailableException('a'));

    await expectLater(done, throwsA(isA<SoundFileUnavailableException>()));
    expect(controller.statusOf(source), SoundPlaybackStatus.idle);
  });

  test('a failed load after a stop is swallowed', () async {
    final source = _source('a');
    final done = controller.toggle('p1', source);

    controller.stop();
    loader.pending['a']!.completeError(SoundFileUnavailableException('a'));

    await expectLater(done, completes);
  });

  test('dispose stops the player', () {
    final other = SoundPlaybackController(
      loader: loader,
      player: player,
      decoder: decoder,
    );
    other.dispose();
    expect(player.stops, 1);
  });

  test('the waveform and a later play share one download', () async {
    final source = _source('a');
    final waveform = controller.waveformOf('p1', source);
    loader.pending['a']!.complete(_file);

    expect((await waveform).duration, const Duration(seconds: 2));
    expect(identical(controller.waveformOf('p1', source), waveform), isTrue);
    final done = controller.toggle('p1', source);
    await pumpEventQueue();

    expect(loader.requests, hasLength(1));
    expect(decoder.decoded, [_file]);
    expect(player.played.single.$1, _file);
    player.finish();
    await done;
  });

  test('a failed download is tried again', () async {
    final source = _source('a');
    final first = controller.waveformOf('p1', source);
    loader.pending['a']!.completeError(SoundFileUnavailableException('a'));
    await expectLater(first, throwsA(isA<SoundFileUnavailableException>()));

    final second = controller.waveformOf('p1', source);
    loader.pending['a']!.complete(_file);

    expect((await second).peaks, [0.5, 1]);
    expect(loader.requests, hasLength(2));
  });

  test('the waveform settles once read and notifies', () async {
    final source = _source('a');
    var notified = 0;
    controller.addListener(() => notified++);
    final waveform = controller.waveformOf('p1', source);

    expect(controller.isWaveformSettled(source), isFalse);
    expect(controller.readWaveformOf(source), isNull);
    loader.pending['a']!.complete(_file);
    await waveform;

    expect(controller.isWaveformSettled(source), isTrue);
    expect(controller.readWaveformOf(source)!.peaks, [0.5, 1]);
    expect(notified, 1);
  });

  test('a failed waveform settles too', () async {
    final source = _source('a');
    final waveform = controller.waveformOf('p1', source);
    loader.pending['a']!.completeError(SoundFileUnavailableException('a'));
    await expectLater(waveform, throwsA(isA<SoundFileUnavailableException>()));

    expect(controller.isWaveformSettled(source), isTrue);
    expect(controller.readWaveformOf(source), isNull);
  });

  test("the position is the player's only while the source plays", () async {
    final source = _source('a');
    player.position = const Duration(milliseconds: 700);
    expect(controller.positionOf(source), Duration.zero);

    final done = controller.toggle('p1', source);
    loader.pending['a']!.complete(_file);
    await pumpEventQueue();

    expect(controller.positionOf(source), const Duration(milliseconds: 700));
    expect(controller.positionOf(_source('b')), Duration.zero);
    player.finish();
    await done;
  });
}
