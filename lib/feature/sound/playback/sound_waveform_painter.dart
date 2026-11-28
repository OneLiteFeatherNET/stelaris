import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// The peaks on the way from [from] to [to] at [t] from 0 to 1. Lists of
/// other lengths are spread over the longer one, an empty one counts as
/// silence; at 1 it is [to] itself.
List<double> lerpPeaks(List<double> from, List<double> to, double t) {
  if (t >= 1 || (from.isEmpty && to.isEmpty)) return to;
  final count = to.isEmpty ? from.length : to.length;
  double at(List<double> peaks, int i) =>
      peaks.isEmpty ? 0 : peaks[i * peaks.length ~/ count];
  return [
    for (var i = 0; i < count; i++) lerpDouble(at(from, i), at(to, i), t)!,
  ];
}

/// Bars of the [peaks] across the width, those already played in [played],
/// the rest in [unplayed]. Without peaks a flat line.
///
/// While [transition] runs, the bars grow from [previous] to [peaks].
/// While [hover] is set, a line in [marker] shows where a tap would jump.
///
/// Repaints from [position], [transition] and [hover] by itself, without the
/// widget building again.
class SoundWaveformPainter extends CustomPainter {
  SoundWaveformPainter({
    required this.peaks,
    required this.duration,
    required this.position,
    required this.played,
    required this.unplayed,
    this.previous = const [],
    this.transition,
    this.hover,
    this.marker,
  }) : super(repaint: Listenable.merge([position, transition, hover]));

  final List<double> peaks;

  /// The peaks shown before [peaks], e.g. of the file played before.
  final List<double> previous;

  /// How far the bars are from [previous] to [peaks]; at [peaks] when null.
  final Animation<double>? transition;

  /// The length of the file; null until its waveform is read.
  final Duration? duration;
  final ValueListenable<Duration> position;
  final Color played;
  final Color unplayed;

  /// Where the mouse is, from 0 to 1; null while it isn't over the waveform.
  final ValueListenable<double?>? hover;
  final Color? marker;

  /// The shortest bar, so silence still shows where the file is.
  static const double _minBar = 2;

  /// The peaks as they are drawn right now.
  List<double> get shownPeaks =>
      lerpPeaks(previous, peaks, transition?.value ?? 1);

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
    final shown = shownPeaks;
    if (shown.isEmpty) {
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
    final step = size.width / shown.length;
    paint.strokeWidth = (step * 0.6).clamp(1.0, 4.0);
    for (var i = 0; i < shown.length; i++) {
      final x = step * (i + 0.5);
      final half = (shown[i] * size.height).clamp(_minBar, size.height) / 2;
      paint.color = x / size.width <= progress ? played : unplayed;
      canvas.drawLine(Offset(x, midY - half), Offset(x, midY + half), paint);
    }
    _paintHover(canvas, size);
  }

  void _paintHover(Canvas canvas, Size size) {
    final at = hover?.value;
    final color = marker;
    if (at == null || color == null) return;
    final x = at * size.width;
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()
        ..color = color
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(SoundWaveformPainter old) =>
      old.peaks != peaks ||
      old.previous != previous ||
      old.transition != transition ||
      old.duration != duration ||
      old.position != position ||
      old.hover != hover ||
      old.marker != marker ||
      old.played != played ||
      old.unplayed != unplayed;
}
