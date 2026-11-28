import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/sound/playback/sound_playback_controller.dart';
import 'package:stelaris/l10n/app_localizations.dart';

/// The tooltip and icon of a play button for [status]: play while idle or
/// paused, pause while playing, and a spinner that stops while loading.
(String, Widget) playButtonContent(
  SoundPlaybackStatus status,
  AppLocalizations l10n,
) => switch (status) {
  SoundPlaybackStatus.idle || SoundPlaybackStatus.paused => (
    l10n.tooltip_sound_play,
    const Icon(Icons.play_arrow),
  ),
  SoundPlaybackStatus.playing => (
    l10n.sound_player_pause,
    const Icon(Icons.pause),
  ),
  SoundPlaybackStatus.loading => (
    l10n.tooltip_sound_stop,
    const SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  ),
};
