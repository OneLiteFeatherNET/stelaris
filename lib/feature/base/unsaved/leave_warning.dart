export 'leave_warning_stub.dart'
    if (dart.library.js_interop) 'leave_warning_web.dart';

/// Turns the browser's "Leave site?" question on closing or reloading the
/// tab on or off.
typedef LeaveWarning = void Function(bool enabled);
