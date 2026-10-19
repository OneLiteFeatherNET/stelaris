import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/feature/base/unsaved/unsaved_changes_guard.dart';
import 'package:stelaris/feature/project/badge/project_labor_badge.dart';
import 'package:stelaris/feature/project/dialog/switch_project_dialog.dart';
import 'package:stelaris/feature/project/switch_to_project.dart';
import 'package:stelaris/feature/settings/settings_card.dart';
import 'package:stelaris/feature/settings/settings_section.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The Project section: the active project, and the choice of another.
class ProjectSettingsRow extends StatelessWidget {
  const ProjectSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, (List<Project>, Project?)>(
      converter: (store) => (store.state.projects, store.state.selectedProject),
      builder: (context, state) {
        final (projects, selectedProject) = state;
        final l10n = context.l10n;

        if (projects.isEmpty) {
          return SettingsSection(
            title: l10n.settings_project_title,
            children: [
              SettingsCard(
                icon: Icons.folder_outlined,
                title: l10n.settings_project_active_title,
                subtitle: l10n.settings_project_empty,
              ),
            ],
          );
        }

        final currentSelected =
            selectedProject != null &&
                projects.any((p) => p.id == selectedProject.id)
            ? projects.firstWhere((p) => p.id == selectedProject.id)
            : projects.first;
        final field = ChoiceEdit<Project>(
          label: l10n.settings_project_active_title,
          icon: Icons.folder_outlined,
          value: currentSelected,
          options: projects,
          display: (project) => '${project.displayName} (${project.key})',
          optionTrailing: (project) =>
              project.labor ? const ProjectLaborBadge(fontSize: 10) : null,
          onChanged: (project) => _switchTo(context, currentSelected, project),
        );

        return SettingsSection(
          title: l10n.settings_project_title,
          children: [
            // A link to the choice, like the cards of the About section.
            SettingsCard(
              icon: field.icon,
              title: field.label,
              subtitle: field.displayValue,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentSelected.labor) ...[
                    const ProjectLaborBadge(fontSize: 10),
                    const SizedBox(width: 8),
                  ],
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => field.pick(context),
            ),
          ],
        );
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
    selectProject(context, target);
  }
}
