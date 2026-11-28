import 'dart:async';
import 'dart:js_interop';

import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/sound_player.dart';
import 'package:web/web.dart' as web;

SoundPlayer createPlatformSoundPlayer() => _WebSoundPlayer();

/// Plays through an `<audio>` element fed from a blob URL.
class _WebSoundPlayer implements SoundPlayer {
  web.HTMLAudioElement? _audio;
  String? _url;
  Completer<void>? _done;

  @override
  Future<void> play(
    SoundFile file, {
    required double volume,
    required double pitch,
    Duration from = Duration.zero,
  }) async {
    stop();
    final blob = web.Blob(
      [file.bytes.toJS].toJS,
      web.BlobPropertyBag(type: file.mimeType),
    );
    final url = web.URL.createObjectURL(blob);
    final done = Completer<void>();
    final audio = web.HTMLAudioElement()
      ..src = url
      ..preservesPitch = false
      // Before the metadata is there, this is where the playback starts.
      ..currentTime = _seconds(from);
    _apply(audio, volume: volume, pitch: pitch);
    audio.onended = ((web.Event _) => _finish(done)).toJS;
    audio.onerror = ((web.Event _) {
      _release(done);
      if (!done.isCompleted) {
        done.completeError(StateError('The browser cannot play this file'));
      }
    }).toJS;
    _audio = audio;
    _url = url;
    _done = done;
    try {
      await audio.play().toDart;
    } catch (error) {
      // Superseded by a stop, or the browser refused to decode the file.
      _release(done);
      if (!done.isCompleted) done.completeError(error);
    }
    return done.future;
  }

  @override
  Duration get position {
    final seconds = _audio?.currentTime ?? 0;
    return Duration(microseconds: (seconds * 1e6).round());
  }

  @override
  void stop() {
    final done = _done;
    if (done != null) _finish(done);
  }

  @override
  void pause() => _audio?.pause();

  @override
  void resume() {
    final audio = _audio;
    if (audio == null || !audio.paused) return;
    final done = _done!;
    audio.play().toDart.catchError((Object error) {
      _release(done);
      if (!done.isCompleted) done.completeError(error);
      return null;
    });
  }

  @override
  void seek(Duration position) => _audio?.currentTime = _seconds(position);

  @override
  void adjust({required double volume, required double pitch}) {
    final audio = _audio;
    if (audio != null) _apply(audio, volume: volume, pitch: pitch);
  }

  /// A volume above 1 only widens the range in the game, so it plays at full
  /// volume here; a pitch is clamped like in Minecraft.
  static void _apply(
    web.HTMLAudioElement audio, {
    required double volume,
    required double pitch,
  }) {
    audio
      ..volume = volume.clamp(0.0, 1.0)
      ..playbackRate = pitch.clamp(0.5, 2.0);
  }

  static double _seconds(Duration duration) => duration.inMicroseconds / 1e6;

  void _finish(Completer<void> done) {
    _release(done);
    if (!done.isCompleted) done.complete();
  }

  /// Frees the element and URL of the playback [done] belongs to, unless a
  /// newer playback took their place.
  void _release(Completer<void> done) {
    if (!identical(_done, done)) return;
    _audio
      ?..pause()
      ..removeAttribute('src');
    final url = _url;
    if (url != null) web.URL.revokeObjectURL(url);
    _audio = null;
    _url = null;
    _done = null;
  }
}
