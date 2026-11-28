import 'dart:async';
import 'dart:js_interop';

import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/playback_timeline.dart';
import 'package:stelaris/feature/sound/playback/sound_player.dart';
import 'package:web/web.dart' as web;

SoundPlayer createPlatformSoundPlayer() => _WebSoundPlayer();

/// How long a voice fades in and out, in seconds. Cutting a wave off mid
/// swing clicks; this is too short to hear as a fade.
const double _fade = 0.015;

/// Plays with Web Audio: the whole file is decoded once and played from
/// memory, so it ends exactly where the file ends, whatever its container
/// claims. Start, pause, seek and stop fade in or out instead of cutting
/// the wave.
///
/// Each start, resume or seek plays a new voice, a buffer source with a
/// gain of its own, so the voice it replaces can fade out meanwhile.
class _WebSoundPlayer implements SoundPlayer {
  web.AudioContext? _context;

  /// The file decoded last and its audio, so playing it again or seeking in
  /// it needs no second decode.
  SoundFile? _decodedFile;
  web.AudioBuffer? _decoded;

  _Playback? _playback;

  /// Created on the first play, which a click starts, so the browser lets
  /// it make sound.
  web.AudioContext get _audio => _context ??= web.AudioContext();

  @override
  Future<void> play(
    SoundFile file, {
    required double volume,
    required double pitch,
    Duration from = Duration.zero,
  }) async {
    stop();
    final playback = _Playback(
      volume: _volumeOf(volume),
      rate: _rateOf(pitch),
      from: _seconds(from),
    );
    _playback = playback;
    final context = _audio;
    // Not awaited: the browser holds a context back until the page was
    // clicked, and the voice then starts as soon as it may.
    if (context.state == 'suspended') context.resume().toDart.ignore();
    try {
      final buffer = await _decode(file);
      // Unless stopped, or superseded, while it decoded.
      if (identical(_playback, playback)) {
        playback.timeline = PlaybackTimeline(duration: buffer.duration)
          ..start(
            at: context.currentTime,
            from: playback.from,
            rate: playback.rate,
          );
        playback.buffer = buffer;
        _startVoice(playback);
      }
    } catch (error) {
      if (identical(_playback, playback)) _playback = null;
      if (!playback.done.isCompleted) {
        playback.done.completeError(
          StateError('The browser cannot play this file: $error'),
        );
      }
    }
    return playback.done.future;
  }

  Future<web.AudioBuffer> _decode(SoundFile file) async {
    final decoded = _decoded;
    if (decoded != null && identical(_decodedFile, file)) return decoded;
    // decodeAudioData takes over the buffer, so it gets a copy.
    final bytes = file.bytes.sublist(0);
    final buffer = await _audio.decodeAudioData(bytes.buffer.toJS).toDart;
    _decodedFile = file;
    _decoded = buffer;
    return buffer;
  }

  @override
  Duration get position {
    final playback = _playback;
    if (playback == null) return Duration.zero;
    final timeline = playback.timeline;
    final seconds = timeline == null
        ? playback.from
        : timeline.positionAt(_audio.currentTime);
    return Duration(microseconds: (seconds * 1e6).round());
  }

  @override
  void stop() {
    final playback = _playback;
    if (playback == null) return;
    _playback = null;
    _fadeOut(playback.voice);
    playback.voice = null;
    if (!playback.done.isCompleted) playback.done.complete();
  }

  @override
  void pause() {
    final playback = _playback;
    final timeline = playback?.timeline;
    if (playback == null || timeline == null || timeline.isPaused) return;
    timeline.pause(at: _audio.currentTime);
    _fadeOut(playback.voice);
    playback.voice = null;
  }

  @override
  void resume() {
    final playback = _playback;
    final timeline = playback?.timeline;
    if (playback == null || timeline == null || !timeline.isPaused) return;
    final context = _audio;
    if (context.state == 'suspended') context.resume().toDart.ignore();
    timeline.resume(at: context.currentTime);
    _startVoice(playback);
  }

  @override
  void seek(Duration position) {
    final playback = _playback;
    if (playback == null) return;
    final seconds = _seconds(position);
    final timeline = playback.timeline;
    // Still decoding: it starts there once decoded.
    if (timeline == null) {
      playback.from = seconds;
      return;
    }
    timeline.seek(seconds, at: _audio.currentTime);
    if (timeline.isPaused) return;
    _fadeOut(playback.voice);
    _startVoice(playback);
  }

  @override
  void adjust({required double volume, required double pitch}) {
    final playback = _playback;
    if (playback == null) return;
    playback
      ..volume = _volumeOf(volume)
      ..rate = _rateOf(pitch);
    final now = _audio.currentTime;
    playback.timeline?.changeRate(playback.rate, at: now);
    final voice = playback.voice;
    if (voice == null) return;
    voice.source.playbackRate.setValueAtTime(playback.rate, now);
    voice.gain.gain
      ..cancelScheduledValues(now)
      ..setValueAtTime(voice.gain.gain.value, now)
      ..linearRampToValueAtTime(playback.volume, now + _fade);
  }

  /// Plays [playback] from the position of its timeline, fading in.
  void _startVoice(_Playback playback) {
    final context = _audio;
    final now = context.currentTime;
    final gain = context.createGain()..connect(context.destination);
    gain.gain
      ..setValueAtTime(0, now)
      ..linearRampToValueAtTime(playback.volume, now + _fade);
    final source = context.createBufferSource()..buffer = playback.buffer;
    source.playbackRate.setValueAtTime(playback.rate, now);
    source.connect(gain);
    final voice = _Voice(source, gain);
    // Only a voice that still plays when the file runs out ends the
    // playback; one faded out has its handler replaced.
    source.onended = ((web.Event _) {
      if (!identical(playback.voice, voice)) return;
      if (identical(_playback, playback)) _playback = null;
      voice.disconnect();
      playback.voice = null;
      if (!playback.done.isCompleted) playback.done.complete();
    }).toJS;
    source.start(now, playback.timeline!.positionAt(now));
    playback.voice = voice;
  }

  /// Fades [voice] out and lets go of it once it is silent.
  void _fadeOut(_Voice? voice) {
    if (voice == null) return;
    final now = _audio.currentTime;
    voice.source.onended = ((web.Event _) => voice.disconnect()).toJS;
    voice.gain.gain
      ..cancelScheduledValues(now)
      ..setValueAtTime(voice.gain.gain.value, now)
      ..linearRampToValueAtTime(0, now + _fade);
    voice.source.stop(now + _fade);
  }

  /// A volume above 1 only widens the range in the game, so it plays at full
  /// volume here.
  static double _volumeOf(double volume) => volume.clamp(0.0, 1.0);

  /// As in Minecraft, a pitch changes the speed and the pitch together and
  /// is clamped.
  static double _rateOf(double pitch) => pitch.clamp(0.5, 2.0);

  static double _seconds(Duration duration) => duration.inMicroseconds / 1e6;
}

/// One play of a file, from [SoundPlayer.play] until it ends or is stopped.
class _Playback {
  _Playback({required this.volume, required this.rate, required this.from});

  final Completer<void> done = Completer<void>();
  double volume;
  double rate;

  /// Where it starts once decoded, in seconds.
  double from;

  /// Set once decoded.
  web.AudioBuffer? buffer;
  PlaybackTimeline? timeline;

  /// The voice that plays; null while paused, decoding or done.
  _Voice? voice;
}

/// A buffer source and the gain it plays through.
class _Voice {
  _Voice(this.source, this.gain);

  final web.AudioBufferSourceNode source;
  final web.GainNode gain;

  void disconnect() {
    source.disconnect();
    gain.disconnect();
  }
}
