import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/sound/sound_page.dart';

class SoundVmFactory extends VmFactory<AppState, SoundPage, SoundViewModel> {
  SoundVmFactory();

  @override
  SoundViewModel fromStore() => SoundViewModel(
    models: state.soundEvents.items,
    hasNextPage: state.soundEvents.hasNextPage,
    isLoadingMore: state.isLoadingMoreSoundEvents,
    projectKey: state.selectedProject!.key,
  );
}

class SoundViewModel extends Vm {
  SoundViewModel({
    required this.models,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.projectKey,
  }) : super(
         equals: [
           models,
           hasNextPage,
           isLoadingMore,
           projectKey,
         ],
       );

  final List<SoundEventModel> models;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String projectKey;
}
