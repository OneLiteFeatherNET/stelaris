import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/advancement/advancement_page.dart';

class AdvancementVmFactory
    extends VmFactory<AppState, AdvancementPage, AdvancementViewModel> {
  AdvancementVmFactory();

  @override
  AdvancementViewModel fromStore() => AdvancementViewModel(
    models: state.advancements.items,
    hasNextPage: state.advancements.hasNextPage,
    isLoadingMore: state.isLoadingMoreAdvancements,
    currentItems: state.advancements.totalItems,
    projectKey: state.selectedProject!.key,
  );
}

class AdvancementViewModel extends Vm {
  final List<AdvancementModel> models;
  final int currentItems;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String projectKey;

  AdvancementViewModel({
    required this.models,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.currentItems,
    required this.projectKey,
  }) : super(
         equals: [models, currentItems, hasNextPage, isLoadingMore, projectKey],
       );
}
