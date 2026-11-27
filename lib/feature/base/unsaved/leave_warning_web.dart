import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// The `beforeunload` listener while the warning is on.
JSFunction? _listener;

/// While [enabled], closing or reloading the tab makes the browser ask
/// whether to leave. Browsers show their own text and ignore the page's.
void setLeaveWarning(bool enabled) {
  if (enabled == (_listener != null)) return;

  if (enabled) {
    final listener = _askBeforeLeaving.toJS;
    web.window.addEventListener('beforeunload', listener);
    _listener = listener;
  } else {
    web.window.removeEventListener('beforeunload', _listener);
    _listener = null;
  }
}

void _askBeforeLeaving(web.BeforeUnloadEvent event) {
  event.preventDefault();
  // Older browsers only ask when returnValue is set.
  event.returnValue = '';
}
