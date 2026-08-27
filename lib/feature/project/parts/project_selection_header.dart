import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

class ProjectSelectionHeader extends StatelessWidget {
  final bool showAddButton;
  final VoidCallback onCreateProject;

  const ProjectSelectionHeader({
    required this.showAddButton,
    required this.onCreateProject,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.folder_shared_outlined,
              color: colorScheme.primary,
              size: 26,
            ),
            horizontalSpacing10,
            Text(
              context.l10n.project_selection_title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (showAddButton)
          IconButton.filledTonal(
            tooltip: context.l10n.dialog_project_create_title,
            icon: const Icon(Icons.add),
            onPressed: onCreateProject,
          ),
      ],
    );
  }
}
