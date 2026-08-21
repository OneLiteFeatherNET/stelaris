import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/project/project_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

import 'dialog/project_create_dialog.dart';

class ProjectSelectionPage extends StatefulWidget {
  const ProjectSelectionPage({super.key});

  @override
  State<ProjectSelectionPage> createState() => _ProjectSelectionPageState();
}

class _ProjectSelectionPageState extends State<ProjectSelectionPage> {
  Project? _selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: StoreConnector<AppState, ProjectViewModel>(
        vm: () => ProjectVmFactory(),
        builder: (context, vm) {
          // Sync local selection with state if null or removed
          if (_selected == null && vm.selectedProject != null) {
            _selected = vm.selectedProject;
          } else if (_selected != null &&
              !vm.projects.any((p) => p.id == _selected!.id)) {
            _selected = vm.projects.isNotEmpty ? vm.projects.first : null;
          } else if (_selected == null && vm.projects.isNotEmpty) {
            _selected = vm.projects.first;
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Branding
                  Image.asset(
                    'assets/logo_stelaris_v1.webp',
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.auto_awesome,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                  ),
                  heightTen,
                  Text(
                    context.l10n.welcome_to_stelaris,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  verticalSpacing25,

                  // Elevated Selection Card
                  Card(
                    elevation: 6,
                    shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: 480,
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card Header with + Button (only shown when projects exist)
                          Row(
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
                              if (vm.projects.isNotEmpty)
                                IconButton.filledTonal(
                                  tooltip: context.l10n.dialog_project_create_title,
                                  icon: const Icon(Icons.add),
                                  onPressed: () => _openCreateDialog(context),
                                ),
                            ],
                          ),
                          const Divider(height: 32),

                          // Card Body
                          if (vm.projects.isEmpty) ...[
                            _buildEmptyState(context, colorScheme, theme),
                          ] else ...[
                            _buildProjectSelector(context, vm, colorScheme, theme),
                            verticalSpacing25,
                            FilledButton.icon(
                              onPressed: _selected == null
                                  ? null
                                  : () => _proceedWithProject(vm),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
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
            onPressed: () => _openCreateDialog(context),
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

  Widget _buildProjectSelector(
    BuildContext context,
    ProjectViewModel vm,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
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
        DropdownButtonFormField<Project>(
          isExpanded: true,
          itemHeight: null,
          borderRadius: BorderRadius.circular(16),
          dropdownColor: colorScheme.surfaceContainerHigh,
          elevation: 3,
          value: _selected,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          selectedItemBuilder: (context) {
            return vm.projects.map((project) {
              return Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: project.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(
                            text: '  (${project.key})',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (project.labor)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LABOR',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                ],
              );
            }).toList();
          },
          items: vm.projects.map((project) {
            return DropdownMenuItem<Project>(
              value: project,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            project.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            project.key,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (project.labor)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'LABOR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (newProject) {
            setState(() {
              _selected = newProject;
            });
          },
        ),
        if (_selected?.description != null &&
            _selected!.description!.isNotEmpty) ...[
          verticalSpacing10,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _selected!.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _openCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateProjectDialog(),
    ).then((created) {
      if (created is Project) {
        setState(() {
          _selected = created;
        });
      }
    });
  }

  void _proceedWithProject(ProjectViewModel vm) {
    if (_selected != null) {
      vm.onSelectProject(_selected!);
      context.go(NavigationEntry.attributes.route);
    }
  }
}
