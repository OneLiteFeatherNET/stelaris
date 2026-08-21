import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/project/project_selection_page.dart';
import 'package:stelaris_models/stelaris_models.dart';

class ProjectVmFactory
    extends VmFactory<AppState, ProjectSelectionPage, ProjectViewModel> {
  ProjectVmFactory();

  @override
  ProjectViewModel fromStore() => ProjectViewModel(
    projects: state.projects,
    selectedProject: state.selectedProject,
    onSelectProject: (project) => dispatch(SelectProjectAction(project)),
  );
}

class ProjectViewModel extends Vm {
  final List<Project> projects;
  final Project? selectedProject;
  final ValueChanged<Project?> onSelectProject;

  ProjectViewModel({
    required this.projects,
    required this.selectedProject,
    required this.onSelectProject,
  }) : super(equals: [projects, selectedProject]);

  bool isSelected(Project project) {
    if (selectedProject == null) return false;
    return selectedProject!.id == project.id;
  }
}
