import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/util/constants.dart';

/// The browser tab's title while there are unsaved edits.
const String unsavedAppTitle = '• $appName';

/// Shows unsaved edits on the browser tab: a dot in front of its title.
class UnsavedBrowserTab extends StatelessWidget {
  const UnsavedBrowserTab({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.unsavedChanges != null,
      distinct: true,
      builder: (context, unsaved) => Title(
        title: unsaved ? unsavedAppTitle : appName,
        color: Theme.of(context).colorScheme.primary.withAlpha(0xFF),
        child: child,
      ),
    );
  }
}
