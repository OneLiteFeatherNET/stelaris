import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// What became of a dispatched action: whether it went through, and the
/// error if it failed. An action can also neither go through nor fail, e.g.
/// when a throttle drops it.
typedef DispatchOutcome = ({bool ok, Object? error});

extension DispatchAndCatch on BuildContext {
  /// Dispatches [action] and waits for it, with any error in the outcome.
  ///
  /// The store has no wrapError, so [dispatchAndWait] rethrows an error from
  /// the backend instead of reporting it in the status. Both end up in
  /// [DispatchOutcome.error] here, nothing is thrown.
  Future<DispatchOutcome> dispatchAndCatch(ReduxAction<AppState> action) async {
    final fallback = l10n.error_title;
    try {
      final status = await dispatchAndWait(action);
      return (
        ok: status.isCompletedOk,
        error: status.isCompletedFailed
            ? status.originalError ?? fallback
            : null,
      );
    } catch (error) {
      return (ok: false, error: error);
    }
  }
}
