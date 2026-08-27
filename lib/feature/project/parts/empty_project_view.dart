import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

class EmptyProjectView extends StatelessWidget {
  final VoidCallback onCreateProject;

  const EmptyProjectView({
    super.key,
    required this.onCreateProject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.create_new_folder_outlined,
            size: 56,
            color: colorScheme.outline,
          ),
          verticalSpacing10,
          Text(
            context.l10n.project_selection_empty_title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          heightTen,
          Text(
            context.l10n.project_selection_empty_subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          verticalSpacing25,
          FilledButton.icon(
            onPressed: onCreateProject,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.dialog_project_create_button),
          ),
        ],
      ),
    );
  }
}
