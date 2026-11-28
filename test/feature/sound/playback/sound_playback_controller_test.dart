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
  final List<Duration> playedFrom = [];
  final List<Duration> seeks = [];
  final List<(double, double)> adjusts = [];
  int stops = 0;
  int pauses = 0;
  int resumes = 0;
  int disposals = 0;

  @override
  void dispose() => disposals++;

  @override
  Future<void> play(
    SoundFile file, {
    required double volume,
    required double pitch,
    Duration from = Duration.zero,
  }) {
    played.add((file, volume, pitch));
    playedFrom.add(from);
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
  void pause() => pauses++;

  @override
  void resume() => resumes++;

  @override
  void seek(Duration position) => seeks.add(position);

  @override
  void adjust({required double volume, required double pitch}) =>
      adjusts.add((volume, pitch));

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

  test('a second toggle of the playing source pauses it', () async {
    final source = _source('a');
    final done = controller.toggle('p1', source);
    loader.pending['a']!.complete(_file);
    await pumpEventQueue();

    await controller.toggle('p1', source);

    expect(player.pauses, 1);
    expect(player.stops, 0);
    expect(controller.statusOf(source), SoundPlaybackStatus.paused);
    controller.stop();
    await done;
  });

  test('a toggle of the loading source stops it', () async {
    final source = _source('a');
    final done = controller.toggle('p1', source);

    await controller.toggle('p1', source);
    loader.pending['a']!.complete(_file);
    await done;

    expect(player.played, isEmpty);
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

  test('dispose lets go of the player, so it frees what it holds', () {
    final other = SoundPlaybackController(
      loader: loader,
      player: player,
      decoder: decoder,
    );
    other.dispose();
    expect(player.disposals, 1);
  });

  test('a play during the waveform read shares its download', () async {
    final source = _source('a');
    final waveform = controller.waveformOf('p1', source);
    final done = controller.toggle('p1', source);
    loader.pending['a']!.complete(_file);

    expect((await waveform).duration, const Duration(seconds: 2));
    expect(identical(controller.waveformOf('p1', source), waveform), isTrue);
    await pumpEventQueue();

    expect(loader.requests, hasLength(1));
    expect(decoder.decoded, [_file]);
    expect(player.played.single.$1, _file);
    player.finish();
    await done;
  });

  test('the audio is let go once the waveform is read', () async {
    final source = _source('a');
    final waveform = controller.waveformOf('p1', source);
    loader.pending['a']!.complete(_file);
    await waveform;

    final done = controller.toggle('p1', source);
    expect(loader.requests, hasLength(2));
    loader.pending['a']!.complete(_file);
    await pumpEventQueue();

    expect(decoder.decoded, hasLength(1));
    expect(player.played.single.$1, _file);
    player.finish();
    await done;
  });

  test('the file played last is kept for the next play', () async {
    final source = _source('a');
    final first = controller.toggle('p1', source);
    loader.pending['a']!.complete(_file);
    await pumpEventQueue();
    player.finish();
    await first;

    final waveform = controller.waveformOf('p1', source);
    await waveform;
    final second = controller.toggle('p1', source);
    await pumpEventQueue();

    expect(loader.requests, hasLength(1));
    expect(player.played, hasLength(2));
    player.finish();
    await second;
  });

  test('playing another file lets go of the one played before', () async {
    final a = _source('a');
    final b = _source('b');
    final first = controller.toggle('p1', a);
    loader.pending['a']!.complete(_file);
    await pumpEventQueue();
    player.finish();
    await first;

    final second = controller.toggle('p1', b);
    loader.pending['b']!.complete(_file);
    await pumpEventQueue();
    player.finish();
    await second;

    final third = controller.toggle('p1', a);
    expect(loader.requests, [('p1', 'a'), ('p1', 'b'), ('p1', 'a')]);
    loader.pending['a']!.complete(_file);
    await pumpEventQueue();
    player.finish();
    await third;
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

  /// Starts [source] and lets its load arrive, so it plays. Gives what
  /// waits for the end of the playback; a future itself would be awaited.
  Future<Future<void> Function()> startPlaying(SoundFileSource source) async {
    final done = controller.play('p1', source);
    loader.pending[source.name]!.complete(_file);
    await pumpEventQueue();
    return () => done;
  }

  group('pause', () {
    test('pauses the playing file and plays it on', () async {
      final source = _source('a');
      final done = await startPlaying(source);

      controller.togglePause();
      expect(player.pauses, 1);
      expect(controller.status, SoundPlaybackStatus.paused);
      expect(controller.statusOf(source), SoundPlaybackStatus.paused);

      controller.togglePause();
      expect(player.resumes, 1);
      expect(controller.status, SoundPlaybackStatus.playing);
      player.finish();
      await done();
    });

    test('a toggle of the paused file plays it on', () async {
      final source = _source('a');
      final done = await startPlaying(source);
      controller.togglePause();

      await controller.toggle('p1', source);

      expect(player.resumes, 1);
      expect(player.stops, 0);
      expect(controller.statusOf(source), SoundPlaybackStatus.playing);
      player.finish();
      await done();
    });

    test('keeps the position of the paused file', () async {
      final source = _source('a');
      final done = await startPlaying(source);
      player.position = const Duration(milliseconds: 400);
      controller.togglePause();

      expect(controller.positionOf(source), const Duration(milliseconds: 400));
      controller.stop();
      await done();
    });

    test('does nothing while nothing plays', () {
      controller.togglePause();
      expect(player.pauses, 0);
      expect(player.resumes, 0);
    });
  });

  group('seek', () {
    test('plays from where it is asked to', () async {
      final source = _source('a');
      final done = controller.play(
        'p1',
        source,
        from: const Duration(milliseconds: 300),
      );
      loader.pending['a']!.complete(_file);
      await pumpEventQueue();

      expect(player.playedFrom, [const Duration(milliseconds: 300)]);
      player.finish();
      await done;
    });

    test('moves the playing and the paused file', () async {
      final done = await startPlaying(_source('a'));
      controller.seek(const Duration(seconds: 1));
      controller.togglePause();
      controller.seek(const Duration(milliseconds: 200));

      expect(player.seeks, [
        const Duration(seconds: 1),
        const Duration(milliseconds: 200),
      ]);
      controller.stop();
      await done();
    });

    test('does nothing while nothing plays', () {
      controller.seek(const Duration(seconds: 1));
      expect(player.seeks, isEmpty);
    });
  });

  group('current', () {
    test('stays once the file ended, until closed', () async {
      final source = _source('a');
      expect(controller.current, isNull);
      final done = await startPlaying(source);
      player.finish();
      await done();

      expect(controller.current, source);
      expect(controller.status, SoundPlaybackStatus.idle);

      controller.close();
      expect(controller.current, isNull);
    });

    test('close stops what plays', () async {
      final done = await startPlaying(_source('a'));
      controller.close();
      await done();
      expect(player.stops, 1);
    });
  });

  group('preview', () {
    test('tries out volume and pitch live without changing the file', () async {
      final source = _source('a', volume: 0.5, pitch: 1);
      final done = await startPlaying(source);

      controller.preview(pitch: 1.5);
      controller.preview(volume: 0.8);

      expect(controller.volumeOf(source), 0.8);
      expect(controller.pitchOf(source), 1.5);
      expect(controller.hasPreview, isTrue);
      expect(player.adjusts, [(0.5, 1.5), (0.8, 1.5)]);
      expect(source.pitch, 1);
      player.finish();
      await done();
    });

    test('the next play of the file uses it', () async {
      final source = _source('a');
      final first = await startPlaying(source);
      player.finish();
      await first();

      controller.preview(volume: 0.3, pitch: 2);
      final second = controller.play('p1', source);
      await pumpEventQueue();

      expect(player.played.last, (_file, 0.3, 2.0));
      player.finish();
      await second;
    });

    test('playing another file drops it', () async {
      final a = _source('a');
      final doneA = await startPlaying(a);
      controller.preview(pitch: 2);

      final doneB = await startPlaying(_source('b'));
      await doneA();

      expect(controller.hasPreview, isFalse);
      expect(controller.pitchOf(a), 1);
      player.finish();
      await doneB();
    });

    test('reset goes back to the values of the file', () async {
      final source = _source('a', volume: 0.5, pitch: 1.2);
      final done = await startPlaying(source);
      controller.preview(volume: 1, pitch: 2);

      controller.resetPreview();

      expect(controller.hasPreview, isFalse);
      expect(player.adjusts.last, (0.5, 1.2));
      player.finish();
      await done();
    });

    test('a saved file takes the place of the current one', () async {
      final source = _source('a');
      final done = await startPlaying(source);
      controller.preview(pitch: 1.5);

      final saved = source.copyWith(pitch: 1.5);
      controller.replaceCurrent(saved);

      expect(controller.current, saved);
      expect(controller.statusOf(saved), SoundPlaybackStatus.playing);
      expect(controller.hasPreview, isFalse);
      expect(controller.pitchOf(saved), 1.5);
      player.finish();
      await done();
    });

    test('another file does not take the place of the current one', () async {
      final source = _source('a');
      final done = await startPlaying(source);

      controller.replaceCurrent(_source('b'));

      expect(controller.current, source);
      player.finish();
      await done();
    });
  });
}
