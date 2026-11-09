import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/sound/playback/sound_playback_controller.dart';
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

  /// Repaints every frame while the file plays, so the progress runs smooth.
  late final Ticker _ticker = createTicker((_) => setState(() {}));

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
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPlayback);
    _ticker.dispose();
    super.dispose();
  }

  Future<SoundWaveform> _readWaveform() =>
      widget.controller.waveformOf(widget.projectId, widget.source);

  void _onPlayback() {
    final playing = _status == SoundPlaybackStatus.playing;
    if (playing && !_ticker.isActive) _ticker.start();
    if (!playing && _ticker.isActive) _ticker.stop();
    setState(() {});
  }

  SoundPlaybackStatus get _status => widget.controller.statusOf(widget.source);

  double get _rate => widget.source.pitch.clamp(0.5, 2.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SizedBox(
      height: 40,
      child: FutureBuilder<SoundWaveform>(
        future: _waveform,
        // A waveform read before shows at once, without an empty frame.
        initialData: widget.controller.readWaveformOf(widget.source),
        builder: (context, snapshot) {
          final waveform = snapshot.data;
          final status = _status;
          final position = widget.controller.positionOf(widget.source);
          final progress =
              waveform == null || waveform.duration == Duration.zero
              ? 0.0
              : (position.inMicroseconds / waveform.duration.inMicroseconds)
                    .clamp(0.0, 1.0);
          return Row(
            children: [
              _PlayButton(status: status, onPressed: widget.onToggle),
              const SizedBox(width: 4),
              Expanded(
                child: CustomPaint(
                  size: const Size.fromHeight(28),
                  painter: _WaveformPainter(
                    peaks: waveform?.peaks ?? const [],
                    progress: progress,
                    played: colorScheme.primary,
                    unplayed: colorScheme.outlineVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _timeLabel(waveform, status, position),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// The length of the file, and how far it is while it plays.
  String _timeLabel(
    SoundWaveform? waveform,
    SoundPlaybackStatus status,
    Duration position,
  ) {
    if (waveform == null) return '–:––';
    final total = _format(waveform.duration * (1 / _rate));
    if (status != SoundPlaybackStatus.playing) return total;
    return '${_format(position * (1 / _rate))} / $total';
  }

  static String _format(Duration duration) {
    final seconds = duration.inSeconds;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}

/// Play while idle; stop while the file loads or plays.
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.status, required this.onPressed});

  final SoundPlaybackStatus status;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (status) {
      SoundPlaybackStatus.idle => IconButton.filledTonal(
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

/// Bars of the [peaks] across the width, those before [progress] in
/// [played], the rest in [unplayed]. Without peaks a flat line.
class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.peaks,
    required this.progress,
    required this.played,
    required this.unplayed,
  });

  final List<double> peaks;
  final double progress;
  final Color played;
  final Color unplayed;

  /// The shortest bar, so silence still shows where the file is.
  static const double _minBar = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final paint = Paint()..strokeCap = StrokeCap.round;
    if (peaks.isEmpty) {
      canvas.drawLine(
        Offset(0, midY),
        Offset(size.width, midY),
        paint
          ..color = unplayed
          ..strokeWidth = _minBar,
      );
      return;
    }
    final step = size.width / peaks.length;
    paint.strokeWidth = (step * 0.6).clamp(1.0, 4.0);
    for (var i = 0; i < peaks.length; i++) {
      final x = step * (i + 0.5);
      final half = (peaks[i] * size.height).clamp(_minBar, size.height) / 2;
      paint.color = x / size.width <= progress ? played : unplayed;
      canvas.drawLine(Offset(x, midY - half), Offset(x, midY + half), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress ||
      old.peaks != peaks ||
      old.played != played ||
      old.unplayed != unplayed;
}
