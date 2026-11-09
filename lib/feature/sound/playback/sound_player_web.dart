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
      ..volume = volume.clamp(0.0, 1.0)
      ..preservesPitch = false
      ..playbackRate = pitch.clamp(0.5, 2.0);
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
