import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/sound/playback/sound_playback_controller.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform_painter.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The player in a sound file card: play or stop, the waveform that fills up
/// as the file plays, and its time.
///
/// Times are shown as they play in the game: a pitch of 2 plays a file in
/// half its length.
class SoundFilePlayer extends StatefulWidget {
  const SoundFilePlayer({
    required this.controller,
    required this.projectId,
    required this.source,
    required this.onToggle,
    super.key,
  });

  final SoundPlaybackController controller;
  final String projectId;
  final SoundFileSource source;

  /// Plays or stops the file; the page reports what goes wrong.
  final VoidCallback onToggle;

  @override
  State<SoundFilePlayer> createState() => _SoundFilePlayerState();
}

class _SoundFilePlayerState extends State<SoundFilePlayer>
    with SingleTickerProviderStateMixin {
  late Future<SoundWaveform> _waveform;
  late SoundPlaybackStatus _status = _statusNow;

  /// The rate the times are shown at, so a tried-out pitch shows in them.
  late double _shownRate = _rate;

  /// How far the file has played, set every frame while it plays. Only the
  /// waveform repaints from it; the player isn't built again.
  final ValueNotifier<Duration> _position = ValueNotifier(Duration.zero);

  /// The whole seconds played, as they play in the game; the time label
  /// rebuilds only when it changes.
  final ValueNotifier<int> _elapsedSeconds = ValueNotifier(0);

  late final Ticker _ticker = createTicker((_) => _syncPosition());

  @override
  void initState() {
    super.initState();
    _waveform = _readWaveform();
    widget.controller.addListener(_onPlayback);
  }

  @override
  void didUpdateWidget(SoundFilePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onPlayback);
      widget.controller.addListener(_onPlayback);
    }
    if (oldWidget.source.assetId != widget.source.assetId ||
        oldWidget.projectId != widget.projectId) {
      _waveform = _readWaveform();
    }
    _status = _statusNow;
    _shownRate = _rate;
    _syncTicker();
    _syncPosition();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPlayback);
    _ticker.dispose();
    _position.dispose();
    _elapsedSeconds.dispose();
    super.dispose();
  }

  Future<SoundWaveform> _readWaveform() =>
      widget.controller.waveformOf(widget.projectId, widget.source);

  SoundPlaybackStatus get _statusNow =>
      widget.controller.statusOf(widget.source);

  /// Builds again only when this file's status or pitch changed, not on
  /// every change of the controller, e.g. another file loading.
  void _onPlayback() {
    final status = _statusNow;
    final rate = _rate;
    _syncTicker();
    _syncPosition();
    if (status != _status || rate != _shownRate) {
      setState(() {
        _status = status;
        _shownRate = rate;
      });
    }
  }

  void _syncTicker() {
    final playing = _statusNow == SoundPlaybackStatus.playing;
    if (playing && !_ticker.isActive) _ticker.start();
    if (!playing && _ticker.isActive) _ticker.stop();
  }

  void _syncPosition() {
    final position = widget.controller.positionOf(widget.source);
    _position.value = position;
    _elapsedSeconds.value = (position * (1 / _rate)).inSeconds;
  }

  /// The pitch it plays with, which may be tried out in the player bar.
  double get _rate => widget.controller.pitchOf(widget.source).clamp(0.5, 2.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return SizedBox(
      height: 40,
      child: FutureBuilder<SoundWaveform>(
        future: _waveform,
        // A waveform read before shows at once, without an empty frame.
        initialData: widget.controller.readWaveformOf(widget.source),
        builder: (context, snapshot) {
          final waveform = snapshot.data;
          return Row(
            children: [
              _PlayButton(status: _status, onPressed: widget.onToggle),
              const SizedBox(width: 4),
              Expanded(
                // Repaints every frame while playing; kept to its own layer
                // so the card around it doesn't repaint with it.
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: const Size.fromHeight(28),
                    painter: SoundWaveformPainter(
                      peaks: waveform?.peaks ?? const [],
                      duration: waveform?.duration,
                      position: _position,
                      played: colorScheme.primary,
                      unplayed: colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _timeLabel(waveform, timeStyle),
            ],
          );
        },
      ),
    );
  }

  /// The length of the file, and how far it is while it plays.
  Widget _timeLabel(SoundWaveform? waveform, TextStyle? style) {
    if (waveform == null) return Text('–:––', style: style);
    final total = _format(waveform.duration * (1 / _rate));
    if (_status != SoundPlaybackStatus.playing &&
        _status != SoundPlaybackStatus.paused) {
      return Text(total, style: style);
    }
    return ValueListenableBuilder<int>(
      valueListenable: _elapsedSeconds,
      builder: (context, seconds, _) =>
          Text('${_format(Duration(seconds: seconds))} / $total', style: style),
    );
  }

  static String _format(Duration duration) {
    final seconds = duration.inSeconds;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}

/// Play while idle or paused; stop while the file loads or plays.
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.status, required this.onPressed});

  final SoundPlaybackStatus status;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (status) {
      SoundPlaybackStatus.idle ||
      SoundPlaybackStatus.paused => IconButton.filledTonal(
        tooltip: l10n.tooltip_sound_play,
        onPressed: onPressed,
        icon: const Icon(Icons.play_arrow),
      ),
      SoundPlaybackStatus.loading => IconButton.filledTonal(
        tooltip: l10n.tooltip_sound_stop,
        onPressed: onPressed,
        icon: const SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      SoundPlaybackStatus.playing => IconButton.filledTonal(
        tooltip: l10n.tooltip_sound_stop,
        onPressed: onPressed,
        icon: const Icon(Icons.stop),
      ),
    };
  }
}
