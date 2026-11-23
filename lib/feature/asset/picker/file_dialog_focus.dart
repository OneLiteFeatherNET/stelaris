import 'package:flutter/foundation.dart';

/// Tracks the browser's file dialog, which takes the window focus while it
/// is open. Flutter reports the focus coming back as a resume, so a load on
/// resume asks [hadFocus] to tell the dialog closing apart from the user
/// coming back to the tab.
abstract final class FileDialogFocus {
  /// How long after the dialog closed a resume still counts as its own; the
  /// focus may come back a moment after the file was chosen.
  static const Duration grace = Duration(seconds: 1);

  /// The time, replaceable so tests can move past [grace].
  @visibleForTesting
  static DateTime Function() now = DateTime.now;

  static int _open = 0;
  static DateTime? _closedAt;

  /// Called when a file dialog opens.
  static void opened() => _open++;

  /// Called when a file dialog closes, chosen or cancelled.
  static void closed() {
    if (_open > 0) _open--;
    _closedAt = now();
  }

  /// Whether a file dialog is open or closed less than [grace] ago.
  static bool get hadFocus {
    if (_open > 0) return true;
    final closedAt = _closedAt;
    return closedAt != null && now().difference(closedAt) < grace;
  }

  @visibleForTesting
  static void reset() {
    _open = 0;
    _closedAt = null;
    now = DateTime.now;
  }
}
