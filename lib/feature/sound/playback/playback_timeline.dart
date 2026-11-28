/// Where a playback is in its file, in seconds of the file's own time, read
/// against a clock that runs in seconds, such as the `currentTime` of an
/// audio context.
///
/// A rate above 1 plays the file faster, so its position runs ahead of the
/// clock. Every position stays within the file's [duration].
class PlaybackTimeline {
  PlaybackTimeline({required this.duration});

  /// The length of the file in seconds.
  final double duration;

  /// The position at [_since] on the clock.
  double _position = 0;
  double _since = 0;
  double _rate = 1;
  bool _paused = true;

  /// Whether it holds its position; also before [start].
  bool get isPaused => _paused;

  /// Runs from [from] at [rate], starting at [at] on the clock.
  void start({required double at, required double from, required double rate}) {
    _position = _clamp(from);
    _since = at;
    _rate = rate;
    _paused = false;
  }

  /// Holds the position it has at [at].
  void pause({required double at}) {
    _position = positionAt(at);
    _since = at;
    _paused = true;
  }

  /// Runs on from the held position, starting at [at].
  void resume({required double at}) {
    _since = at;
    _paused = false;
  }

  /// Moves to [position] at [at], running on from there unless paused.
  void seek(double position, {required double at}) {
    _position = _clamp(position);
    _since = at;
  }

  /// Runs at [rate] from [at] on.
  void changeRate(double rate, {required double at}) {
    _position = positionAt(at);
    _since = at;
    _rate = rate;
  }

  /// The position at [at] on the clock.
  double positionAt(double at) {
    if (_paused) return _position;
    return _clamp(_position + (at - _since) * _rate);
  }

  double _clamp(double position) => position.clamp(0, duration).toDouble();
}
