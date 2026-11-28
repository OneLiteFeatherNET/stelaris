import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/sound/playback/play_button_content.dart';
import 'package:stelaris/feature/sound/playback/sound_playback_controller.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The play button of a sound file card: play while idle or paused, pause
/// while it plays, stop while it loads. The waveform and the time are in the
/// player bar.
///
/// Builds again only when the status of its own file changes, not on every
/// change of the controller, e.g. another file loading.
class SoundFilePlayButton extends StatefulWidget {
  const SoundFilePlayButton({
    required this.controller,
    required this.source,
    required this.onPressed,
    super.key,
  });

  final SoundPlaybackController controller;
  final SoundFileSource source;

  /// Plays, pauses or stops the file; the page reports what goes wrong.
  final VoidCallback onPressed;

  @override
  State<SoundFilePlayButton> createState() => _SoundFilePlayButtonState();
}

class _SoundFilePlayButtonState extends State<SoundFilePlayButton> {
  late SoundPlaybackStatus _status = _statusNow;

  SoundPlaybackStatus get _statusNow =>
      widget.controller.statusOf(widget.source);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPlayback);
  }

  @override
  void didUpdateWidget(SoundFilePlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onPlayback);
      widget.controller.addListener(_onPlayback);
    }
    _status = _statusNow;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPlayback);
    super.dispose();
  }

  void _onPlayback() {
    final status = _statusNow;
    if (status != _status) setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    final (tooltip, icon) = playButtonContent(_status, context.l10n);
    return IconButton.filledTonal(
      key: const Key('sound_file_play'),
      tooltip: tooltip,
      onPressed: widget.onPressed,
      icon: icon,
    );
  }
}
