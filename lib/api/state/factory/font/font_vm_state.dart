import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/font/font_page.dart';

class FontVmFactory extends VmFactory<AppState, FontPage, FontViewModel> {
  FontVmFactory();

  @override
  FontViewModel fromStore() => FontViewModel(
    models: state.fonts.items,
    selected: state.selectedFont,
    hasNextPage: state.fonts.hasNextPage,
    isLoadingMore: state.isLoadingMoreFonts,
    projectKey: state.selectedProject!.key,
    projects: state.projects,
    currentProject: state.selectedProject!,
  );
}

class FontViewModel extends Vm {
  final List<FontModel> models;
  final FontModel? selected;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String projectKey;
  final List<Project> projects;
  final Project currentProject;

  FontViewModel({
    required this.models,
    required this.selected,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.projectKey,
    required this.projects,
    required this.currentProject,
  }) : super(
         equals: [
           models,
           selected,
           hasNextPage,
           isLoadingMore,
           projectKey,
           projects,
           currentProject,
         ],
       );

  bool isSelectedItem(FontModel model) {
    if (selected == null) return false;

    final selectedModel = selected!;

    if (selectedModel.id != null && model.id != null) {
      return selectedModel.id == model.id;
    }
    return selectedModel.hashCode == model.hashCode;
  }
}
