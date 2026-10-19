import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/util/dispatch_ext.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Selects the project a location names before showing the page below it.
///
/// When [projectId] is selected already, [child] shows right away.
/// Otherwise it is selected (see [EnsureProjectSelectedAction]) and a
/// spinner shows until then; when that fails the person is sent to the
/// project list with a notice, since the project is gone or out of reach.
class ProjectGate extends StatefulWidget {
  const ProjectGate({required this.projectId, required this.child, super.key});

  final String projectId;
  final Widget child;

  @override
  State<ProjectGate> createState() => _ProjectGateState();
}

class _ProjectGateState extends State<ProjectGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _select());
  }

  @override
  void didUpdateWidget(ProjectGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _select());
    }
  }

  bool _isSelected(AppState state) =>
      state.selectedProject?.id == widget.projectId;

  Future<void> _select() async {
    if (!mounted) return;
    if (_isSelected(StoreProvider.state<AppState>(context))) return;
    final outcome = await context.dispatchAndCatch(
      EnsureProjectSelectedAction(widget.projectId),
    );
    if (!mounted || outcome.ok) return;
    context.showWarningSnackBar(context.l10n.snackbar_project_not_found);
    context.go(projectsRoute);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => _isSelected(store.state),
      builder: (context, isSelected) => isSelected
          ? widget.child
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
