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

class InitFontAction extends ReduxAction<AppState> {

  InitFontAction();

  @override
  Future<AppState?> reduce() async {
    final List<SoundEventModel> sounds = await ApiService().soundAPI.getAll();
    if (sounds.isEmpty) return null;
    return state.copyWith(soundEvents: sounds);
  }
}

class RemoveFontsAction extends ReduxAction<AppState> {
  final SoundEventModel model;

  RemoveFontsAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final removed = await ApiService().soundAPI.remove(model);
    final sounds = List.of(state.soundEvents, growable: true);
    sounds.remove(removed);
    return state.copyWith(soundEvents: sounds);
  }
}

class AddFontAction extends ReduxAction<AppState> {
  final SoundEventModel _model;

  AddFontAction(this._model);

  @override
  Future<AppState?> reduce() async {
    final SoundEventModel added = await ApiService().soundAPI.add(_model);
    final List<SoundEventModel> sounds = List.of(state.soundEvents, growable: true);
    sounds.add(added);
    return state.copyWith(soundEvents: sounds, selectedSoundEvent: added);
  }
}

class UpdateFontAction extends ReduxAction<AppState> {
  final SoundEventModel newEntry;

  UpdateFontAction(this.newEntry);

  @override
  Future<AppState?> reduce() async => state.copyWith(selectedSoundEvent: newEntry);
}

class FontDatabaseUpdate extends ReduxAction<AppState> {

  FontDatabaseUpdate();

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