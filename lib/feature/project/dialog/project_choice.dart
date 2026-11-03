import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/feature/base/unsaved/unsaved_changes_guard.dart';
import 'package:stelaris/feature/project/badge/project_labor_badge.dart';
import 'package:stelaris/feature/project/dialog/switch_project_dialog.dart';
import 'package:stelaris/util/dispatch_ext.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The choice of the active project among [projects], starting at [current].
/// Picking another project asks for confirmation before switching to it.
ChoiceEdit<Project> projectChoice(
  BuildContext context, {
  required List<Project> projects,
  required Project current,
}) {
  return ChoiceEdit<Project>(
    label: context.l10n.settings_project_active_title,
    icon: Icons.folder_outlined,
    value: current,
    options: projects,
    display: (project) => '${project.displayName} (${project.key})',
    optionTrailing: (project) =>
        project.labor ? const ProjectLaborBadge(fontSize: 10) : null,
    onChanged: (project) => _switchTo(context, current, project),
    refresh: () async {
      final (:ok, :error) = await context.dispatchAndCatch(
        InitProjectAction(),
      );
      if (!ok) throw error!;
      if (!context.mounted) return projects;
      return StoreProvider.state<AppState>(context).projects;
    },
  );
}

Future<void> _switchTo(
  BuildContext context,
  Project current,
  Project target,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) =>
        SwitchProjectDialog(currentProject: current, targetProject: target),
  );

  if (confirmed != true || !context.mounted) return;
  // Switching drops the current selection, including any unsaved edits on
  // an open detail page.
  if (!await confirmLeaveIfDirty(context) || !context.mounted) return;
  context.dispatch(SelectProjectAction(target));
}
