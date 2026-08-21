import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Action to set or clear the currently selected project for the session.
class SelectProjectAction extends ReduxAction<AppState> {
  final Project? project;

  SelectProjectAction(this.project);

  @override
  AppState reduce() {
    return state.copyWith(selectedProject: project);
  }
}

/// Action to add a new project to the available projects list.
/// Optionally selects the newly created project immediately.
class AddProjectAction extends ReduxAction<AppState> {
  final Project project;
  final bool select;

  AddProjectAction(this.project, {this.select = true});

  @override
  AppState reduce() {
    final updatedProjects = List<Project>.of(state.projects)..add(project);
    return state.copyWith(
      projects: updatedProjects,
      selectedProject: select ? project : state.selectedProject,
    );
  }
}

/// Action to replace the list of available projects.
class SetProjectsAction extends ReduxAction<AppState> {
  final List<Project> projects;

  SetProjectsAction(this.projects);

  @override
  AppState reduce() {
    return state.copyWith(projects: projects);
  }
}

/// Action to remove a project from the available list.
class RemoveProjectAction extends ReduxAction<AppState> {
  final Project project;

  RemoveProjectAction(this.project);

  @override
  AppState reduce() {
    final updatedProjects = List<Project>.of(state.projects)
      ..removeWhere((p) => p.id == project.id);
    final updatedSelected = state.selectedProject?.id == project.id
        ? null
        : state.selectedProject;
    return state.copyWith(
      projects: updatedProjects,
      selectedProject: updatedSelected,
    );
  }
}
