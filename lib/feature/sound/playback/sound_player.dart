import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/sound_player_stub.dart'
    if (dart.library.js_interop) 'package:stelaris/feature/sound/playback/sound_player_web.dart';

/// Plays one sound file at a time.
abstract interface class SoundPlayer {
  /// The player of the platform: the browser's audio outside of tests.
  factory SoundPlayer() => createPlatformSoundPlayer();

  /// Plays [file] and completes when it ends or [stop] cuts it off.
  ///
  /// [volume] and [pitch] are those of the sound file. As in Minecraft, a
  /// pitch changes the speed and the pitch together and is clamped to
  /// 0.5..2; a volume above 1 only widens the range in the game, so it
  /// plays at full volume here.
  Future<void> play(
    SoundFile file, {
    required double volume,
    required double pitch,
  });

  /// Stops the file that plays, if any.
  void stop();

  /// How far the file that plays is, in the file's own time; zero when none
  /// plays.
  Duration get position;
}
