import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/settings/settings_base_row.dart';
import 'package:stelaris/feature/settings/settings_item.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

class ProjectSettingsRow extends StatelessWidget {
  const ProjectSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StoreConnector<AppState, (List<Project>, Project?)>(
      converter: (store) => (store.state.projects, store.state.selectedProject),
      builder: (context, state) {
        final (projects, selectedProject) = state;
        if (projects.isEmpty) return const SizedBox.shrink();

        final currentSelected = selectedProject != null &&
                projects.any((p) => p.id == selectedProject.id)
            ? projects.firstWhere((p) => p.id == selectedProject.id)
            : projects.first;

        return SettingsBaseRow(
          title: context.l10n.settings_project_title,
          child: SettingsItem(
            title: context.l10n.settings_project_active_title,
            subtitle: context.l10n.settings_project_active_subtitle,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Project>(
                  isDense: true,
                  value: currentSelected,
                  borderRadius: BorderRadius.circular(10),
                  dropdownColor: colorScheme.surfaceContainerHigh,
                  elevation: 3,
                  onChanged: (p) {
                    if (p != null) context.dispatch(SelectProjectAction(p));
                  },
                  items: projects.map((project) {
                    return DropdownMenuItem<Project>(
                      value: project,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            project.displayName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${project.key})',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (project.labor) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'LABOR',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
