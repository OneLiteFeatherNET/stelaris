import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/project/project_selection_page.dart';
import 'package:stelaris_models/stelaris_models.dart';

class ProjectVmFactory
    extends VmFactory<AppState, ProjectSelectionPage, ProjectViewModel> {
  final Project? localSelection;

  ProjectVmFactory({this.localSelection});

  @override
  ProjectViewModel fromStore() => ProjectViewModel(
    projects: state.projects,
    selected: _resolveSelected(
      state.projects,
      localSelection ?? state.selectedProject,
    ),
    onSelectProject: (project) => dispatch(SelectProjectAction(project)),
  );

  // A project's id is only assigned once persisted, so a project picked
  // locally before the store reconciles it must also be matched by key.
  Project? _resolveSelected(List<Project> projects, Project? candidate) {
    if (projects.isEmpty) return null;
    if (candidate != null) {
      final match = projects
          .where((p) => p.id == candidate.id || p.key == candidate.key)
          .firstOrNull;
      if (match != null) return match;
    }
    return projects.first;
  }
}

class ProjectViewModel extends Vm {
  final List<Project> projects;
  final Project? selected;
  final ValueChanged<Project?> onSelectProject;

  ProjectViewModel({
    required this.projects,
    required this.selected,
    required this.onSelectProject,
  }) : super(equals: [projects, selected]);
}
