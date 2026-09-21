import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/attributes/attribute_page.dart';

class AttributeVmFactory
    extends VmFactory<AppState, AttributePage, AttributeViewModel> {
  AttributeVmFactory();

  @override
  AttributeViewModel fromStore() => AttributeViewModel(
    models: state.attributes.items,
    selected: state.selectedAttribute,
    totalItems: state.attributes.totalItems,
    hasNextPage: state.attributes.hasNextPage,
    isLoadingMore: state.isLoadingAttributesMore,
    projectKey: state.selectedProject!.key,
    projects: state.projects,
    currentProject: state.selectedProject!,
  );
}

class AttributeViewModel extends Vm {
  final List<AttributeModel> models;
  final AttributeModel? selected;
  final int totalItems;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String projectKey;
  final List<Project> projects;
  final Project currentProject;

  AttributeViewModel({
    required this.models,
    required this.selected,
    required this.totalItems,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.projectKey,
    required this.projects,
    required this.currentProject,
  }) : super(
         equals: [
           models,
           selected,
           totalItems,
           hasNextPage,
           isLoadingMore,
           projectKey,
           projects,
           currentProject,
         ],
       );

  bool isSelectedItem(AttributeModel model) {
    if (selected == null) return false;

    final selectedModel = selected!;

    if (selectedModel.id != null && model.id != null) {
      return selectedModel.id == model.id;
    }
    return selectedModel.hashCode == model.hashCode;
  }
}
