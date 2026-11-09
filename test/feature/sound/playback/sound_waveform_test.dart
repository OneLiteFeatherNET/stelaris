import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform.dart';

void main() {
  test('takes the loudest sample of each bucket, scaled to the loudest', () {
    final samples = Float32List.fromList([0.1, -0.5, 0.25, 0, -0.2, 0.05]);

    final waveform = SoundWaveform.fromSamples(
      samples,
      sampleRate: 6,
      buckets: 3,
    );

    expect(waveform.peaks, [1.0, 0.5, 0.4]);
    expect(waveform.duration, const Duration(seconds: 1));
  });

  test('spreads fewer samples than buckets over the buckets', () {
    final waveform = SoundWaveform.fromSamples(
      Float32List.fromList([0.5, 1]),
      sampleRate: 2,
      buckets: 4,
    );

    expect(waveform.peaks, [0.5, 0.5, 1.0, 1.0]);
  });

  test('silence stays flat', () {
    final waveform = SoundWaveform.fromSamples(
      Float32List(8),
      sampleRate: 8,
      buckets: 4,
    );

    expect(waveform.peaks, [0.0, 0.0, 0.0, 0.0]);
  });

  test('no samples give no peaks', () {
    final waveform = SoundWaveform.fromSamples(
      Float32List(0),
      sampleRate: 44100,
      buckets: 4,
    );

    expect(waveform.peaks, isEmpty);
    expect(waveform.duration, Duration.zero);
  });
}
