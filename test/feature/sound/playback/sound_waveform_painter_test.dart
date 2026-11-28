import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/sound/playback/sound_waveform_painter.dart';

void main() {
  group('lerpPeaks', () {
    test('goes from one waveform to the other', () {
      expect(lerpPeaks([0, 1], [1, 0], 0), [0, 1]);
      expect(lerpPeaks([0, 1], [1, 0], 0.5), [0.5, 0.5]);
      expect(lerpPeaks([0, 1], [1, 0], 1), [1, 0]);
    });

    test('grows out of silence', () {
      expect(lerpPeaks(const [], [0.4, 1], 0.5), [0.2, 0.5]);
    });

    test('sinks into silence when the new one has no peaks yet', () {
      expect(lerpPeaks([0.4, 1], const [], 0.5), [0.2, 0.5]);
      expect(lerpPeaks([0.4, 1], const [], 1), isEmpty);
    });

    test('spreads a shorter waveform over the longer one', () {
      expect(lerpPeaks([1], [0, 0, 0, 0], 0), [1, 1, 1, 1]);
    });

    test('stays empty without any peaks', () {
      expect(lerpPeaks(const [], const [], 0.5), isEmpty);
    });
  });
}
