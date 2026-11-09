import 'dart:js_interop';

import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/sound_decoder.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';
import 'package:web/web.dart' as web;

SoundDecoder createPlatformSoundDecoder() => _WebSoundDecoder();

/// Decodes with Web Audio. An offline context needs no user gesture and
/// plays nothing; it only lends its decoder.
class _WebSoundDecoder implements SoundDecoder {
  /// Low on purpose: the waveform needs no detail, and decoding resamples to
  /// this rate, which keeps the samples to scan few.
  static const int _sampleRate = 8000;

  @override
  Future<SoundWaveform> waveform(SoundFile file, {int buckets = 64}) async {
    final context = web.OfflineAudioContext(
      web.OfflineAudioContextOptions(
        numberOfChannels: 1,
        length: 1,
        sampleRate: _sampleRate,
      ),
    );
    // decodeAudioData takes over the buffer, so it gets a copy.
    final bytes = file.bytes.sublist(0);
    final buffer = await context.decodeAudioData(bytes.buffer.toJS).toDart;
    return SoundWaveform.fromSamples(
      buffer.getChannelData(0).toDart,
      sampleRate: buffer.sampleRate.round(),
      buckets: buckets,
    );
  }
}
