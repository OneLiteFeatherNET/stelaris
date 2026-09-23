import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';

/// How a backend command's outcome reads once its action has finished.
enum BackendOutcome { success, neutral, failure }

/// Dispatches [action] and reports the outcome in a snackbar.
///
/// Not every action this app has says when it failed. The `Refresh*Action`s
/// throw, which [Store.dispatchAndWait] passes on because the store has no
/// error observer. Others catch everything and leave a trace in the state
/// instead, which is what [outcome] is for: it looks at the state before and
/// after and decides. Without it, a completed action counts as a success.
///
/// The messenger and the store are captured before the first `await`, because
/// the palette is already closed by then and nothing guarantees [context]
/// outlives the request.
Future<void> runBackendCommand(
  BuildContext context,
  ReduxAction<AppState> action, {
  required String success,
  required String failure,
  String? neutral,
  BackendOutcome Function(AppState before, AppState after)? outcome,
}) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final Store<AppState> store = StoreProvider.backdoorInheritedWidget<AppState>(
    context,
  );
  final AppState before = store.state;

  BackendOutcome result;
  try {
    final ActionStatus status = await store.dispatchAndWait(action);
    result = status.isCompletedFailed
        ? BackendOutcome.failure
        : (outcome?.call(before, store.state) ?? BackendOutcome.success);
  } catch (_) {
    result = BackendOutcome.failure;
  }

  final InfoBarFactory bars = InfoBarFactory();
  messenger.showSnackBar(switch (result) {
    BackendOutcome.success => bars.createSuccess(success),
    BackendOutcome.neutral => bars.createInfo(neutral ?? success),
    BackendOutcome.failure => bars.createErrorText(failure),
  });
}
