import 'package:flutter/foundation.dart';
import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/sound_decoder.dart';
import 'package:stelaris/feature/sound/playback/sound_player.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';
import 'package:stelaris_models/stelaris_models.dart';

enum SoundPlaybackStatus { idle, loading, playing }

/// Plays the sound files of a sound event, one at a time, and outlines them.
///
/// Starting a file stops the one before. A load or playback that a stop or a
/// newer start has superseded neither plays nor reports its failure.
///
/// A file is downloaded once for its waveform and its playbacks; a failed
/// download is tried again on the next request.
class SoundPlaybackController extends ChangeNotifier {
  SoundPlaybackController({
    required this.loader,
    required this.player,
    required this.decoder,
  });

  final SoundFileLoader loader;
  final SoundPlayer player;
  final SoundDecoder decoder;

  final Map<String, Future<SoundFile>> _files = {};
  final Map<String, Future<SoundWaveform>> _waveforms = {};

  /// The waveforms read so far, and the files whose waveform failed, so a
  /// card can wait until its waveform settles either way.
  final Map<String, SoundWaveform> _readWaveforms = {};
  final Set<String> _failedWaveforms = {};
  bool _disposed = false;

  SoundFileSource? _active;
  SoundPlaybackStatus _status = SoundPlaybackStatus.idle;

  /// Counts the starts and stops, so a pending one can tell it was superseded.
  int _generation = 0;

  SoundPlaybackStatus statusOf(SoundFileSource source) =>
      source == _active ? _status : SoundPlaybackStatus.idle;

  /// How far [source] has played, in the file's own time; zero unless it
  /// plays.
  Duration positionOf(SoundFileSource source) =>
      statusOf(source) == SoundPlaybackStatus.playing
      ? player.position
      : Duration.zero;

  /// The waveform of [source] of [projectId]. Notifies the listeners once it
  /// is read or failed.
  Future<SoundWaveform> waveformOf(String projectId, SoundFileSource source) {
    final key = _keyOf(source);
    return _cached(_waveforms, key, () async {
      try {
        final waveform = await decoder.waveform(await _file(projectId, source));
        _readWaveforms[key] = waveform;
        _failedWaveforms.remove(key);
        return waveform;
      } catch (_) {
        _failedWaveforms.add(key);
        rethrow;
      } finally {
        if (!_disposed) notifyListeners();
      }
    });
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

  /// Plays [source] of [projectId], or stops it if it is the active one.
  ///
  /// Completes when the playback ends. Throws what the load or the player
  /// threw, e.g. a [SoundFileUnavailableException].
  Future<void> toggle(String projectId, SoundFileSource source) async {
    if (source == _active) {
      stop();
      return;
    }
    stop();
    final generation = _generation;
    _set(source, SoundPlaybackStatus.loading);
    try {
      final file = await _file(projectId, source);
      if (generation != _generation) return;
      _set(source, SoundPlaybackStatus.playing);
      await player.play(file, volume: source.volume, pitch: source.pitch);
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
