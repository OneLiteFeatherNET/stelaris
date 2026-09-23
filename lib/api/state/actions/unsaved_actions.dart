import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';

extension UnsavedChangesState on AppState {
  /// Clears [unsavedChanges] if it belongs to [entry], leaving another
  /// section's pending edits untouched.
  AppState clearUnsavedChanges(NavigationEntry entry) =>
      unsavedChanges == entry ? copyWith(unsavedChanges: null) : this;
}

/// Drops the pending-edits flag without saving. The form update actions
/// only ever touch the selection (never the list), so nothing has to be
/// rolled back: leaving the detail page removes the selection anyway.
class DiscardUnsavedChangesAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    if (state.unsavedChanges == null) return null;
    return state.copyWith(unsavedChanges: null);
  }
}

/// Marks [entry] as having unsaved edits while a text field is still being
/// typed in — the fields only commit their value (via the Update…Actions)
/// on submit or blur, which would leave the Save action disabled until then.
class MarkUnsavedChangesAction extends ReduxAction<AppState> {
  MarkUnsavedChangesAction(this.entry);

  final NavigationEntry entry;

  @override
  AppState? reduce() {
    if (state.unsavedChanges == entry) return null;
    return state.copyWith(unsavedChanges: entry);
  }
}
