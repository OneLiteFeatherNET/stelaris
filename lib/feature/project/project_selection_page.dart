import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/project/project_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

import 'dialog/project_create_dialog.dart';
import 'dialog/project_edit_dialog.dart';
import 'parts/project_selection_card.dart';

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
        onInit: (store) => store.dispatchAndWait(InitProjectAction()),
        vm: () => ProjectVmFactory(localSelection: _selected),
        builder: (context, vm) {
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
                  ProjectSelectionCard(
                    projects: vm.projects,
                    selected: vm.selected,
                    onSelectProject: (project) =>
                        setState(() => _selected = project),
                    onEditProject: (project) =>
                        _openEditDialog(context, project),
                    onCreateProject: () => _openCreateDialog(context),
                    onProceed: () => _proceedWithProject(vm, vm.selected!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openCreateDialog(BuildContext context) {
    _openProjectDialog(context, (context) => const CreateProjectDialog());
  }

  void _openEditDialog(BuildContext context, Project project) {
    _openProjectDialog(
      context,
      (context) => EditProjectDialog(project: project),
    );
  }

  void _openProjectDialog(BuildContext context, WidgetBuilder builder) {
    showDialog<Project>(context: context, builder: builder).then((result) {
      if (result != null) {
        setState(() => _selected = result);
      }
    });
  }

  void _proceedWithProject(ProjectViewModel vm, Project selected) {
    vm.onSelectProject(selected);
    context.go(NavigationEntry.attributes.route);
  }
}
