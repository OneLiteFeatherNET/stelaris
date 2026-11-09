import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/sound_player.dart';

/// Outside the web build there is no audio element to play with.
SoundPlayer createPlatformSoundPlayer() => _UnsupportedSoundPlayer();

class _UnsupportedSoundPlayer implements SoundPlayer {
  @override
  Future<void> play(
    SoundFile file, {
    required double volume,
    required double pitch,
  }) => Future.error(UnsupportedError('Sound playback needs the web build'));

  @override
  void stop() {}

  @override
  Duration get position => Duration.zero;
}
