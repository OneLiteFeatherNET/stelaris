import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/project/dialog/switch_project_dialog.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Switches to [target], asking first when a project ([current]) is open,
/// since switching drops unsaved changes and the loaded lists.
Future<void> switchToProject(
  BuildContext context,
  Project? current,
  Project target,
) async {
  if (current != null) {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) =>
          SwitchProjectDialog(currentProject: current, targetProject: target),
    );
    if (confirmed != true || !context.mounted) return;
  }
  selectProject(context, target);
}

/// Selects [target] and, on a page below a project, moves on to the same
/// section of [target]: the route names the project, and a page left on the
/// old one would wait for it to be selected again. A detail page goes to
/// the list, as its model belongs to the old project.
///
/// The route changes after the selection, which drops unsaved edits, so the
/// detail page's exit guard does not ask about them a second time.
void selectProject(BuildContext context, Project target) {
  final String? location = GoRouter.maybeOf(context)?.state.matchedLocation;
  context.dispatch(SelectProjectAction(target));
  final NavigationEntry? entry = location == null
      ? null
      : entryForLocation(location);
  if (entry != null && entry.projectScoped) {
    context.go(sectionLocation(entry, target.id));
  }
}
