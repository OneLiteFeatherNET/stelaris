import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
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
  context.dispatch(SelectProjectAction(target));
}
