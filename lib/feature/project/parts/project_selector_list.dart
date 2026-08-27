import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

import 'project_list_tile.dart';

class ProjectSelectorList extends StatefulWidget {
  final List<Project> projects;
  final Project? selected;
  final ValueChanged<Project> onSelect;
  final ValueChanged<Project> onEdit;

  const ProjectSelectorList({
    super.key,
    required this.projects,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
  });

  @override
  State<ProjectSelectorList> createState() => _ProjectSelectorListState();
}

class _ProjectSelectorListState extends State<ProjectSelectorList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.project_selection_dropdown_label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        heightTen,
        // Sunken / Recessed Container
        Material(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 280, minHeight: 80),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: ListView.separated(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: widget.projects.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                itemBuilder: (context, index) {
                  final project = widget.projects[index];
                  return ProjectListTile(
                    project: project,
                    isSelected: widget.selected?.id == project.id,
                    onSelect: () => widget.onSelect(project),
                    onEdit: () => widget.onEdit(project),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
