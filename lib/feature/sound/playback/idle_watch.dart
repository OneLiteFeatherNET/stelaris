import 'dart:async';

/// Calls [onIdle] once something has stayed idle for [after], unless it got
/// busy again before.
class IdleWatch {
  IdleWatch({required this.after, required this.onIdle});

  final Duration after;
  final void Function() onIdle;

  Timer? _timer;

  /// Starts counting, from the start again if it already counts.
  void idle() {
    _timer?.cancel();
    _timer = Timer(after, () {
      _timer = null;
      onIdle();
    });
  }

  /// Stops counting.
  void busy() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => busy();
}
