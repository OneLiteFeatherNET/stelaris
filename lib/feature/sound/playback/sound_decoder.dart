import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/sound_decoder_stub.dart'
    if (dart.library.js_interop) 'package:stelaris/feature/sound/playback/sound_decoder_web.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';

/// Reads the waveform of a sound file.
abstract interface class SoundDecoder {
  /// The decoder of the platform: the browser's Web Audio outside of tests.
  factory SoundDecoder() => createPlatformSoundDecoder();

  /// Decodes [file] and outlines it in [buckets] slices.
  Future<SoundWaveform> waveform(SoundFile file, {int buckets});
}
