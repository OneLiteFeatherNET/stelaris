import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/sound/sound_page.dart';

class SoundVmFactory extends VmFactory<AppState, SoundPage, SoundViewModel> {
  SoundVmFactory();

  @override
  SoundViewModel fromStore() => SoundViewModel(
    models: state.soundEvents.items,
    selected: state.selectedSoundEvent,
    hasNextPage: state.soundEvents.hasNextPage,
    isLoadingMore: state.isLoadingMoreSoundEvents,
    projectKey: state.selectedProject!.key,
    projects: state.projects,
    currentProject: state.selectedProject!,
  );
}

class SoundViewModel extends Vm {
  SoundViewModel({
    required this.models,
    required this.selected,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.projectKey,
    required this.projects,
    required this.currentProject,
  }) : super(
         equals: [
           selected,
           models,
           hasNextPage,
           isLoadingMore,
           projectKey,
           projects,
           currentProject,
         ],
       );

  final SoundEventModel? selected;
  final List<SoundEventModel> models;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String projectKey;
  final List<Project> projects;
  final Project currentProject;

  bool isSelectedItem(SoundEventModel model) {
    if (selected == null) return false;

    final selectedModel = selected!;

    if (selectedModel.id != null && model.id != null) {
      return selectedModel.id == model.id;
    }
    return selectedModel.hashCode == model.hashCode;
  }
}
