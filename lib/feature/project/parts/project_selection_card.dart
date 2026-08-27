import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

import 'empty_project_view.dart';
import 'project_selection_header.dart';
import 'project_selector_list.dart';

class ProjectSelectionCard extends StatelessWidget {
  final List<Project> projects;
  final Project? selected;
  final ValueChanged<Project> onSelectProject;
  final ValueChanged<Project> onEditProject;
  final VoidCallback onCreateProject;
  final VoidCallback onProceed;

  const ProjectSelectionCard({
    super.key,
    required this.projects,
    required this.selected,
    required this.onSelectProject,
    required this.onEditProject,
    required this.onCreateProject,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 6,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: 520,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProjectSelectionHeader(
                showAddButton: projects.isNotEmpty,
                onCreateProject: onCreateProject,
              ),
              const Divider(height: 32),
              if (projects.isEmpty) ...[
                EmptyProjectView(onCreateProject: onCreateProject),
              ] else ...[
                ProjectSelectorList(
                  projects: projects,
                  selected: selected,
                  onSelect: onSelectProject,
                  onEdit: onEditProject,
                ),
                verticalSpacing25,
                FilledButton.icon(
                  onPressed: selected == null ? null : onProceed,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    context.l10n.project_selection_open_button,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
