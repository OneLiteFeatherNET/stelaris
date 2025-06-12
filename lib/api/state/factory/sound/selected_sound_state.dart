import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/model/sound/sound_event_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/sound/sound_general_page.dart';

class SelectedSoundState
    extends VmFactory<AppState, SoundGeneralPage, SelectedSoundView> {
  SelectedSoundState();

  @override
  SelectedSoundView fromStore() =>
      SelectedSoundView(selected: state.selectedSoundEvent!);
}

class SelectedSoundView extends Vm {
  SelectedSoundView({required this.selected}) : super(equals: [selected]);

  final SoundEventModel selected;

}
