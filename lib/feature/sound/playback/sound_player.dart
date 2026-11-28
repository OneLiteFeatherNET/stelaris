import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/feature/sound/playback/sound_player_stub.dart'
    if (dart.library.js_interop) 'package:stelaris/feature/sound/playback/sound_player_web.dart';

/// Plays one sound file at a time.
abstract interface class SoundPlayer {
  /// The player of the platform: the browser's audio outside of tests.
  factory SoundPlayer() => createPlatformSoundPlayer();

  /// Plays [file] from [from], in the file's own time, and completes when it
  /// ends or [stop] cuts it off. A pause doesn't complete it.
  ///
  /// [volume] and [pitch] are those of the sound file. As in Minecraft, a
  /// pitch changes the speed and the pitch together and is clamped to
  /// 0.5..2; a volume above 1 only widens the range in the game, so it
  /// plays at full volume here.
  Future<void> play(
    SoundFile file, {
    required double volume,
    required double pitch,
    Duration from = Duration.zero,
  });

  /// Stops the file that plays, if any.
  void stop();

  /// Holds the file that plays where it is.
  void pause();

  /// Plays the held file on from where [pause] held it.
  void resume();

  /// Moves the file that plays, or is held, to [position], in the file's own
  /// time.
  void seek(Duration position);

  /// Changes the volume and pitch of the file that plays, or is held, as
  /// [play] takes them.
  void adjust({required double volume, required double pitch});

  /// Stops what plays and frees what the player holds, such as the
  /// browser's audio. The player is not used afterwards.
  void dispose();

  /// How far the file that plays is, in the file's own time; zero when none
  /// plays.
  Duration get position;
}
