import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/item/item_page.dart';

class ItemVmFactory extends VmFactory<AppState, ItemPage, ItemViewModel> {
  ItemVmFactory();

  @override
  ItemViewModel fromStore() => ItemViewModel(
    itemModels: state.items.items,
    selected: state.selectedItem,
    hasNextPage: state.items.hasNextPage,
    isLoadingMore: state.isLoadingMoreItems,
    projectKey: state.selectedProject!.key,
    projects: state.projects,
    currentProject: state.selectedProject!,
  );
}

class ItemViewModel extends Vm {
  final List<ItemModel> itemModels;
  final ItemModel? selected;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String projectKey;
  final List<Project> projects;
  final Project currentProject;

  ItemViewModel({
    required this.itemModels,
    required this.selected,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.projectKey,
    required this.projects,
    required this.currentProject,
  }) : super(
         equals: [
           itemModels,
           selected,
           hasNextPage,
           isLoadingMore,
           projectKey,
           projects,
           currentProject,
         ],
       );

  bool isSelectedItem(ItemModel model) {
    if (selected == null) return false;

    final selectedModel = selected!;

    if (selectedModel.id != null && model.id != null) {
      return selectedModel.id == model.id;
    }
    return selectedModel.hashCode == model.hashCode;
  }
}
