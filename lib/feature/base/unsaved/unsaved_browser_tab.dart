import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/unsaved/leave_warning.dart';
import 'package:stelaris/util/constants.dart';

/// The browser tab's title while there are unsaved edits.
const String unsavedAppTitle = '• $appName';

/// Shows unsaved edits on the browser tab: a dot in front of its title, and
/// the browser asks before the tab is closed or reloaded. Leaving within
/// the app is asked about by the detail pages themselves.
class UnsavedBrowserTab extends StatelessWidget {
  const UnsavedBrowserTab({
    required this.child,
    this.leaveWarning = setLeaveWarning,
    super.key,
  });

  final Widget child;

  /// Turns the browser's question on and off; tests pass their own.
  final LeaveWarning leaveWarning;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.unsavedChanges != null,
      distinct: true,
      onInitialBuild: (_, _, unsaved) => leaveWarning(unsaved),
      onDidChange: (_, _, unsaved) => leaveWarning(unsaved),
      onDispose: (_) => leaveWarning(false),
      builder: (context, unsaved) => Title(
        title: unsaved ? unsavedAppTitle : appName,
        color: Theme.of(context).colorScheme.primary.withAlpha(0xFF),
        child: child,
      ),
    );
  }
}
