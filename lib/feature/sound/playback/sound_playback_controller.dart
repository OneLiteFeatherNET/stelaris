import 'package:flutter/foundation.dart';
import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/sound_decoder.dart';
import 'package:stelaris/feature/sound/playback/sound_player.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';
import 'package:stelaris_models/stelaris_models.dart';

enum SoundPlaybackStatus { idle, loading, playing, paused }

/// Plays the sound files of a sound event, one at a time, and outlines them.
///
/// Starting a file stops the one before. A load or playback that a stop or a
/// newer start has superseded neither plays nor reports its failure.
///
/// The file started last is the [current] one, also once it ended, until
/// [close]. Its volume and pitch can be tried out with [preview] without
/// changing the file; they apply live and to its next plays.
///
/// The waveform of a file is kept, its audio is not: a sound event may hold
/// many large files, and each card reads a waveform. Only the file played
/// last stays, so playing it again needs no download. A request that meets a
/// download under way shares it; a failed download is tried again on the next
/// request.
class SoundPlaybackController extends ChangeNotifier {
  SoundPlaybackController({
    required this.loader,
    required this.player,
    required this.decoder,
  });

  final SoundFileLoader loader;
  final SoundPlayer player;
  final SoundDecoder decoder;

  /// The downloads under way and the file played last, see [_playedKey].
  final Map<String, Future<SoundFile>> _files = {};

  /// The key of the one file whose audio outlives its use.
  String? _playedKey;
  final Map<String, Future<SoundWaveform>> _waveforms = {};

  /// The waveforms read so far, and the files whose waveform failed, so a
  /// card can wait until its waveform settles either way.
  final Map<String, SoundWaveform> _readWaveforms = {};
  final Set<String> _failedWaveforms = {};
  bool _disposed = false;

  SoundFileSource? _active;
  SoundPlaybackStatus _status = SoundPlaybackStatus.idle;

  SoundFileSource? _current;
  double? _previewVolume;
  double? _previewPitch;

  /// The file started last, until [close]; null before the first start.
  SoundFileSource? get current => _current;

  /// The status of the [current] file.
  SoundPlaybackStatus get status =>
      _active == null ? SoundPlaybackStatus.idle : _status;

  /// The volume [source] plays with: tried out by [preview] for the
  /// [current] file, otherwise its own.
  double volumeOf(SoundFileSource source) =>
      source == _current ? _previewVolume ?? source.volume : source.volume;

  /// The pitch [source] plays with, like [volumeOf].
  double pitchOf(SoundFileSource source) =>
      source == _current ? _previewPitch ?? source.pitch : source.pitch;

  /// Whether the [current] file plays with another volume or pitch than its
  /// own.
  bool get hasPreview {
    final current = _current;
    if (current == null) return false;
    return volumeOf(current) != current.volume ||
        pitchOf(current) != current.pitch;
  }

  /// Counts the starts and stops, so a pending one can tell it was superseded.
  int _generation = 0;

  SoundPlaybackStatus statusOf(SoundFileSource source) =>
      source == _active ? _status : SoundPlaybackStatus.idle;

  /// How far [source] has played, in the file's own time; zero unless it
  /// plays or is paused.
  Duration positionOf(SoundFileSource source) => switch (statusOf(source)) {
    SoundPlaybackStatus.playing ||
    SoundPlaybackStatus.paused => player.position,
    _ => Duration.zero,
  };

  /// The waveform of [source] of [projectId]. Notifies the listeners once it
  /// is read or failed.
  Future<SoundWaveform> waveformOf(String projectId, SoundFileSource source) {
    final key = _keyOf(source);
    return _cached(_waveforms, key, () async {
      final file = _file(projectId, source);
      try {
        final waveform = await decoder.waveform(await file);
        _readWaveforms[key] = waveform;
        _failedWaveforms.remove(key);
        return waveform;
      } catch (_) {
        _failedWaveforms.add(key);
        rethrow;
      } finally {
        _release(key, file);
        if (!_disposed) notifyListeners();
      }
    });
  }

  /// Lets go of the audio the waveform under [key] was read from, unless a
  /// playback holds on to it or a newer download took its place.
  void _release(String key, Future<SoundFile> file) {
    if (key != _playedKey && identical(_files[key], file)) _files.remove(key);
  }

  /// Makes [key] the one file that is kept, in place of the one before.
  void _keepForPlayback(String key) {
    final previous = _playedKey;
    _playedKey = key;
    if (previous != null && previous != key) _files.remove(previous);
  }

  /// The waveform of [source] once it is read, otherwise null.
  SoundWaveform? readWaveformOf(SoundFileSource source) =>
      _readWaveforms[_keyOf(source)];

  /// Whether the waveform of [source] is read or failed to read.
  bool isWaveformSettled(SoundFileSource source) {
    final key = _keyOf(source);
    return _readWaveforms.containsKey(key) || _failedWaveforms.contains(key);
  }

  Future<SoundFile> _file(String projectId, SoundFileSource source) =>
      _cached(_files, _keyOf(source), () => loader.load(projectId, source));

  /// The asset is what is downloaded; a source without one is keyed by name.
  static String _keyOf(SoundFileSource source) =>
      source.assetId ?? 'name:${source.name}';

  /// The future [cache] holds under [key], or a new one of [create] that
  /// leaves the cache again if it fails.
  static Future<T> _cached<T>(
    Map<String, Future<T>> cache,
    String key,
    Future<T> Function() create,
  ) {
    if (cache[key] case final cached?) return cached;
    final future = create();
    cache[key] = future;
    // Only watches for the failure; the caller still receives it.
    future.then<void>(
      (_) {},
      onError: (Object _) {
        if (identical(cache[key], future)) cache.remove(key);
      },
    );
    return future;
  }

  /// Plays [source] of [projectId], plays it on if it is paused, or stops it
  /// if it loads or plays.
  ///
  /// Completes when the playback ends. Throws what the load or the player
  /// threw, e.g. a [SoundFileUnavailableException].
  Future<void> toggle(String projectId, SoundFileSource source) async {
    if (source != _active) return play(projectId, source);
    if (_status == SoundPlaybackStatus.paused) {
      togglePause();
    } else {
      stop();
    }
  }

  /// Plays [source] of [projectId] from [from], in the file's own time,
  /// stopping what plays. Another file than the [current] one drops what
  /// [preview] tried out.
  ///
  /// Completes when the playback ends. Throws what the load or the player
  /// threw, e.g. a [SoundFileUnavailableException].
  Future<void> play(
    String projectId,
    SoundFileSource source, {
    Duration from = Duration.zero,
  }) async {
    stop();
    if (source != _current) {
      _current = source;
      _previewVolume = null;
      _previewPitch = null;
    }
    final generation = _generation;
    _set(source, SoundPlaybackStatus.loading);
    _keepForPlayback(_keyOf(source));
    try {
      final file = await _file(projectId, source);
      if (generation != _generation) return;
      _set(source, SoundPlaybackStatus.playing);
      await player.play(
        file,
        volume: volumeOf(source),
        pitch: pitchOf(source),
        from: from,
      );
    } catch (_) {
      if (generation != _generation) return;
      rethrow;
    } finally {
      if (generation == _generation) {
        _generation++;
        _set(null, SoundPlaybackStatus.idle);
      }
    }
  }

  /// Pauses the file that plays, or plays the paused one on.
  void togglePause() {
    switch (_status) {
      case SoundPlaybackStatus.playing:
        player.pause();
        _set(_active, SoundPlaybackStatus.paused);
      case SoundPlaybackStatus.paused:
        player.resume();
        _set(_active, SoundPlaybackStatus.playing);
      case SoundPlaybackStatus.idle || SoundPlaybackStatus.loading:
        break;
    }
  }

  /// Moves the file that plays, or is paused, to [position], in the file's
  /// own time.
  void seek(Duration position) {
    if (_status != SoundPlaybackStatus.playing &&
        _status != SoundPlaybackStatus.paused) {
      return;
    }
    player.seek(position);
    notifyListeners();
  }

  /// Tries out [volume] and [pitch] on the [current] file, live while it
  /// plays, without changing the file.
  void preview({double? volume, double? pitch}) {
    final current = _current;
    if (current == null) return;
    if (volume != null) _previewVolume = volume;
    if (pitch != null) _previewPitch = pitch;
    _adjust(current);
  }

  /// Drops what [preview] tried out.
  void resetPreview() {
    final current = _current;
    if (current == null) return;
    _previewVolume = null;
    _previewPitch = null;
    _adjust(current);
  }

  /// Takes [updated] in place of the [current] file it is a newer version
  /// of, e.g. once the tried-out values are saved, and drops the preview.
  void replaceCurrent(SoundFileSource updated) {
    final current = _current;
    if (current == null || _keyOf(current) != _keyOf(updated)) return;
    _current = updated;
    if (_active == current) _active = updated;
    _previewVolume = null;
    _previewPitch = null;
    _adjust(updated);
  }

  /// Stops and forgets the [current] file.
  void close() {
    stop();
    _current = null;
    _previewVolume = null;
    _previewPitch = null;
    notifyListeners();
  }

  void _adjust(SoundFileSource source) {
    if (_active == source) {
      player.adjust(volume: volumeOf(source), pitch: pitchOf(source));
    }
    notifyListeners();
  }

  /// Stops whatever loads or plays.
  void stop() {
    if (_active == null) return;
    _generation++;
    player.stop();
    _set(null, SoundPlaybackStatus.idle);
  }

  void _set(SoundFileSource? source, SoundPlaybackStatus status) {
    _active = source;
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    player.stop();
    super.dispose();
  }
}
