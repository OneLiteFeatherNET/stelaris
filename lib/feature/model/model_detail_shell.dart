import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/page_header.dart';

/// The shared shell for every [ModelPage] detail route: a [PageHeader]
/// (back arrow, model name, unsaved-changes dot and the page's [actions])
/// on its own row at the top, with [body] filling the remaining space.
///
/// Leaving with unsaved form edits — the back arrow, system/browser back or
/// any other navigation — is guarded by the detail route's `onExit`
/// (detailExitGuard), not here.
class ModelDetailShell extends StatelessWidget {
  const ModelDetailShell({
    required this.entry,
    required this.body,
    this.title,
    this.actions = const [],
    super.key,
  });

  /// The section this detail page belongs to; back leads to its list.
  final NavigationEntry entry;
  final String? title;
  final List<Widget> actions;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.unsavedChanges == entry,
      builder: (context, hasUnsavedChanges) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: PageHeader(
                title: title ?? '',
                onBack: () => context.go(entry.route),
                showUnsavedIndicator: hasUnsavedChanges,
                actions: actions,
              ),
            ),
            Expanded(child: body),
          ],
        );
      },
    );
  }
}
