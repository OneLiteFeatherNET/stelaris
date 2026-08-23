import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
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

/// Action to fetch projects from the backend API.
class InitProjectAction extends ReduxAction<AppState> {
  final int page;
  final int size;

  InitProjectAction({this.page = 1, this.size = 50});

  @override
  Future<AppState?> reduce() async {
    final paginatedResult = await ApiService().projectApi.getPage(
      page: page,
      size: size,
    );
    final fetchedProjects = paginatedResult.items;

    Project? updatedSelected = state.selectedProject;
    if (updatedSelected != null) {
      final matchIndex = fetchedProjects.indexWhere(
        (p) => p.id == updatedSelected!.id || p.key == updatedSelected.key,
      );
      if (matchIndex != -1) {
        updatedSelected = fetchedProjects[matchIndex];
      }
    }

    return state.copyWith(
      projects: fetchedProjects,
      selectedProject: updatedSelected,
    );
  }
}

/// Action to add a new project via the backend API and update state.
/// Optionally selects the newly created project immediately.
class AddProjectAction extends ReduxAction<AppState> {
  final Project project;
  final bool select;

  AddProjectAction(this.project, {this.select = true});

  @override
  Future<AppState?> reduce() async {
    final created = await ApiService().projectApi.add(project);
    final updatedProjects = List<Project>.of(state.projects)..add(created);
    return state.copyWith(
      projects: updatedProjects,
      selectedProject: select ? created : state.selectedProject,
    );
  }
}

/// Action to update an existing project via the backend API and update state.
class UpdateProjectAction extends ReduxAction<AppState> {
  final Project project;

  UpdateProjectAction(this.project);

  @override
  Future<AppState?> reduce() async {
    final updated = await ApiService().projectApi.update(project);
    final updatedProjects = List<Project>.of(state.projects);
    final index = updatedProjects.indexWhere(
      (p) => p.id == updated.id || p.key == updated.key,
    );
    if (index != -1) {
      updatedProjects[index] = updated;
    } else {
      updatedProjects.add(updated);
    }
    final updatedSelected =
        (state.selectedProject?.id == updated.id ||
                state.selectedProject?.key == updated.key)
            ? updated
            : state.selectedProject;
    return state.copyWith(
      projects: updatedProjects,
      selectedProject: updatedSelected,
    );
  }
}

/// Action to replace the list of available projects locally.
class SetProjectsAction extends ReduxAction<AppState> {
  final List<Project> projects;

  SetProjectsAction(this.projects);

  @override
  AppState reduce() {
    return state.copyWith(projects: projects);
  }
}

/// Action to remove a project from the backend API and state.
class RemoveProjectAction extends ReduxAction<AppState> {
  final Project project;

  RemoveProjectAction(this.project);

  @override
  Future<AppState?> reduce() async {
    await ApiService().projectApi.remove(project);
    final updatedProjects = List<Project>.of(state.projects)
      ..removeWhere((p) => p.id == project.id || p.key == project.key);
    final updatedSelected =
        (state.selectedProject?.id == project.id ||
                state.selectedProject?.key == project.key)
            ? null
            : state.selectedProject;
    return state.copyWith(
      projects: updatedProjects,
      selectedProject: updatedSelected,
    );
  }
}

/// Action to delete all projects from the backend and clear local state.
class DeleteAllProjectsAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    await ApiService().projectApi.deleteAll();
    return state.copyWith(
      projects: const [],
      selectedProject: null,
    );
  }
}

