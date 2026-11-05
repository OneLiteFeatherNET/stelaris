import 'package:stelaris/feature/auth/session_indicator.dart';
import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/project/project_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
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
      // This page sits outside the shell that carries the app bar, and it is
      // the first thing anyone sees after signing in - and where they stay if
      // they have no project. Without this there is no way to sign out of it.
      // Renders nothing where no identity provider is configured, so an
      // unauthenticated deployment looks exactly as it did.
      body: Stack(
        children: [
          const Positioned(
            top: 8,
            right: 8,
            child: SafeArea(child: SessionIndicator()),
          ),
          StoreConnector<AppState, ProjectViewModel>(
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
        ],
      ),
    );
  }

  /// Opens the create dialog. A created project is selected, and a snackbar
  /// offers to set up its pack right away.
  Future<void> _openCreateDialog(BuildContext context) async {
    final created = await _openProjectDialog(
      context,
      (context) => const CreateProjectDialog(),
    );
    if (created == null || !mounted) return;
    this.context.showSuccessSnackBar(
      this.context.l10n.project_created(created.displayName),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: this.context.l10n.project_created_set_up_pack,
        onPressed: () {
          if (!mounted) return;
          _openEditDialog(this.context, created, tab: EditProjectTab.pack);
        },
      ),
    );
  }

  void _openEditDialog(
    BuildContext context,
    Project project, {
    EditProjectTab tab = EditProjectTab.project,
  }) {
    _openProjectDialog(
      context,
      (context) => EditProjectDialog(project: project, initialTab: tab),
    );
  }

  Future<Project?> _openProjectDialog(
    BuildContext context,
    WidgetBuilder builder,
  ) async {
    final result = await showDialog<Project>(
      context: context,
      builder: builder,
    );
    if (result != null && mounted) {
      setState(() => _selected = result);
    }
    return result;
  }

  void _proceedWithProject(ProjectViewModel vm, Project selected) {
    // An offer to set up the pack only works on this page.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    vm.onSelectProject(selected);
    context.go(NavigationEntry.attributes.route);
  }
}
