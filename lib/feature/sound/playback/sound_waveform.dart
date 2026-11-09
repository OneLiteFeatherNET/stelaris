import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// The outline of a sound file: how loud each slice of it is, and how long
/// it plays at pitch 1.
@immutable
class SoundWaveform {
  const SoundWaveform({required this.peaks, required this.duration});

  /// The waveform of [samples] played at [sampleRate], in [buckets] slices.
  ///
  /// Each peak is the loudest sample of its slice, scaled so the loudest
  /// slice is 1; a silent file stays at 0.
  factory SoundWaveform.fromSamples(
    Float32List samples, {
    required int sampleRate,
    int buckets = 64,
  }) {
    final duration = Duration(
      microseconds:
          samples.length * Duration.microsecondsPerSecond ~/ sampleRate,
    );
    if (samples.isEmpty) {
      return SoundWaveform(peaks: const [], duration: duration);
    }
    final peaks = List<double>.filled(buckets, 0);
    for (var b = 0; b < buckets; b++) {
      final start = b * samples.length ~/ buckets;
      // At least one sample, so a short file still fills every bucket.
      final end = math.max(start + 1, (b + 1) * samples.length ~/ buckets);
      var peak = 0.0;
      for (var i = start; i < end; i++) {
        peak = math.max(peak, samples[i].abs());
      }
      peaks[b] = peak;
    }
    final loudest = peaks.reduce(math.max);
    return SoundWaveform(
      peaks: [
        // Rounded so float noise of the samples doesn't show in tests.
        for (final peak in peaks)
          loudest == 0 ? 0 : (peak / loudest * 1000).round() / 1000,
      ],
      duration: duration,
    );
  }

  /// Loudness of each slice from 0 to 1.
  final List<double> peaks;

  /// How long the file plays at pitch 1.
  final Duration duration;
}
