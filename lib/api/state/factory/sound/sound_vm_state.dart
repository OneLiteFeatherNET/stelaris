import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/model/sound/sound_event_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/sound/sound_page.dart';

class SoundVmFactory extends VmFactory<AppState, SoundPage, SoundViewModel> {
  SoundVmFactory();

  @override
  SoundViewModel fromStore() => SoundViewModel(
    models: state.soundEvents,
    selected: state.selectedSoundEvent,
  );
}

class SoundViewModel extends Vm {
  SoundViewModel({required this.models, required this.selected})
    : super(equals: [selected, models]);

  final SoundEventModel? selected;
  final List<SoundEventModel> models;

  bool isSelectedItem(SoundEventModel model) {
    if (selected == null) return false;

    final selectedModel = selected!;

    if (selectedModel.id != null && model.id != null) {
      return selectedModel.id == model.id;
    }
    return selectedModel.hashCode == model.hashCode;
  }
}
