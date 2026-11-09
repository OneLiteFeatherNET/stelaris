import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/sound_decoder.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';

/// Outside the web build there is no audio decoder.
SoundDecoder createPlatformSoundDecoder() => _UnsupportedSoundDecoder();

class _UnsupportedSoundDecoder implements SoundDecoder {
  @override
  Future<SoundWaveform> waveform(SoundFile file, {int buckets = 64}) =>
      Future.error(UnsupportedError('Decoding sounds needs the web build'));
}
