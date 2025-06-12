import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/sound/sound_event_model.dart';
import 'package:stelaris/api/state/app_state.dart';

class SelectSoundAction extends ReduxAction<AppState> {
  final SoundEventModel model;

  SelectSoundAction(this.model);

  @override
  AppState reduce() => state.copyWith(selectedSoundEvent: model);
}

class RemoveSelectedSoundEvent extends ReduxAction<AppState> {

  @override
  AppState? reduce() {
    if (state.selectedFont == null) return null;
    return state.copyWith(selectedSoundEvent: null);
  }
}

class InitSoundAction extends ReduxAction<AppState> {

  InitSoundAction();

  @override
  Future<AppState?> reduce() async {
    final List<SoundEventModel> sounds = await ApiService().soundAPI.getAll();
    if (sounds.isEmpty) return null;
    return state.copyWith(soundEvents: sounds);
  }
}

class RemoveSoundAction extends ReduxAction<AppState> {
  final SoundEventModel model;

  RemoveSoundAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final removed = await ApiService().soundAPI.remove(model);
    final sounds = List.of(state.soundEvents, growable: true);
    sounds.remove(removed);
    return state.copyWith(soundEvents: sounds);
  }
}

class AddSoundAction extends ReduxAction<AppState> {
  final SoundEventModel _model;

  AddSoundAction(this._model);

  @override
  Future<AppState?> reduce() async {
    final SoundEventModel added = await ApiService().soundAPI.add(_model);
    final List<SoundEventModel> sounds = List.of(state.soundEvents, growable: true);
    sounds.add(added);
    return state.copyWith(soundEvents: sounds, selectedSoundEvent: added);
  }
}

class UpdateSoundAction extends ReduxAction<AppState> {
  final SoundEventModel newEntry;

  UpdateSoundAction(this.newEntry);

  @override
  Future<AppState?> reduce() async => state.copyWith(selectedSoundEvent: newEntry);
}

class SoundDatabaseUpdate extends ReduxAction<AppState> {

  SoundDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedFont == null) return null;
    final SoundEventModel selected = state.selectedSoundEvent!;
    final SoundEventModel dbModel = await ApiService().soundAPI.update(selected);
    final List<SoundEventModel> models = List.of(state.soundEvents, growable: true);
    final int index = models.indexWhere((element) => element.id == selected.id);
    models.removeAt(index);
    models.insert(index, dbModel);
    return state.copyWith(soundEvents: models, selectedSoundEvent: dbModel);
  }
}