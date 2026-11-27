import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// Bars of the [peaks] across the width, those already played in [played],
/// the rest in [unplayed]. Without peaks a flat line.
///
/// Repaints from [position] by itself, without the widget building again.
class SoundWaveformPainter extends CustomPainter {
  SoundWaveformPainter({
    required this.peaks,
    required this.duration,
    required this.position,
    required this.played,
    required this.unplayed,
  }) : super(repaint: position);

  final List<double> peaks;

  /// The length of the file; null until its waveform is read.
  final Duration? duration;
  final ValueListenable<Duration> position;
  final Color played;
  final Color unplayed;

  /// The shortest bar, so silence still shows where the file is.
  static const double _minBar = 2;

  double get _progress {
    final total = duration;
    if (total == null || total == Duration.zero) return 0;
    return (position.value.inMicroseconds / total.inMicroseconds).clamp(
      0.0,
      1.0,
    );
  }

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
    final progress = _progress;
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
  bool shouldRepaint(SoundWaveformPainter old) =>
      old.peaks != peaks ||
      old.duration != duration ||
      old.position != position ||
      old.played != played ||
      old.unplayed != unplayed;
}
