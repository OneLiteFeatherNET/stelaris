import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/sound/playback/playback_timeline.dart';

void main() {
  /// A timeline of a 10 second file that started at clock 100 from [from]
  /// at [rate].
  PlaybackTimeline started({double from = 0, double rate = 1}) =>
      PlaybackTimeline(duration: 10)..start(at: 100, from: from, rate: rate);

  test('is at zero before it starts', () {
    expect(PlaybackTimeline(duration: 10).positionAt(5), 0);
  });

  test('runs with the clock from where it started', () {
    final timeline = started(from: 2);

    expect(timeline.positionAt(103), 5);
  });

  test('runs faster at a higher rate', () {
    final timeline = started(rate: 2);

    expect(timeline.positionAt(103), 6);
  });

  test('holds where it was paused, and runs on from there', () {
    final timeline = started()..pause(at: 104);

    expect(timeline.positionAt(110), 4);
    expect(timeline.isPaused, isTrue);

    timeline.resume(at: 120);
    expect(timeline.isPaused, isFalse);
    expect(timeline.positionAt(121), 5);
  });

  test('a change of rate counts from that moment on', () {
    final timeline = started()..changeRate(2, at: 103);

    expect(timeline.positionAt(104), 5);
  });

  test('a seek moves it while it runs and while it is paused', () {
    final timeline = started()..seek(7, at: 102);
    expect(timeline.positionAt(103), 8);

    timeline
      ..pause(at: 103)
      ..seek(1, at: 105);
    expect(timeline.positionAt(108), 1);
  });

  test('stays within the file', () {
    final timeline = started();

    expect(timeline.positionAt(130), 10);

    timeline.seek(-3, at: 101);
    expect(timeline.positionAt(101), 0);

    timeline.seek(42, at: 101);
    expect(timeline.positionAt(101), 10);
  });

  test('starts within the file', () {
    expect(started(from: 12).positionAt(100), 10);
  });
}
