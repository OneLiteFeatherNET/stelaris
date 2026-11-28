import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/project/badge/project_labor_badge.dart';
import 'package:stelaris/feature/project/parts/project_pack_icon.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

class ProjectListTile extends StatelessWidget {
  final Project project;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;

  /// The pack icon of the project, shown in front of it once it is loaded.
  final Future<ProjectPackIcon?>? packIcon;

  const ProjectListTile({
    required this.project,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    this.packIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // A tinted background alone is easy to miss, and a pack icon hides the
    // filled folder that marks the selection otherwise. The bar on the left
    // makes it clear which project Open Project opens. Unselected tiles keep
    // a transparent bar, so their content doesn't shift on selection.
    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      shape: Border(
        left: BorderSide(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          width: 3,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: ProjectLeading(icon: packIcon, isSelected: isSelected),
        title: Row(
          children: [
            Flexible(
              child: Text(
                project.displayName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
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
              const SizedBox(width: 8),
              const ProjectLaborBadge(),
            ],
          ],
        ),
        subtitle: project.description != null && project.description!.isNotEmpty
            ? Text(
                project.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          tooltip: context.l10n.project_selection_edit_tooltip,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          onPressed: onEdit,
        ),
        onTap: onSelect,
      ),
    );
  }
}
