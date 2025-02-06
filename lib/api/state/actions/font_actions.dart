import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/font_model.dart';
import 'package:stelaris/api/state/app_state.dart';

class SelectFontAction extends ReduxAction<AppState> {
  final FontModel model;

  SelectFontAction(this.model);

  @override
  AppState reduce() => state.copyWith(selectedFont: model);
 }

class RemoveSelectedFont extends ReduxAction<AppState> {

  @override
  AppState? reduce() {
    if (state.selectedFont == null) return null;
    return state.copyWith(selectedFont: null);
  }
}

class InitFontAction extends ReduxAction<AppState> {

  InitFontAction();

  @override
  Future<AppState?> reduce() async {
    final List<FontModel> fonts = await ApiService().fontAPI.getAll();
    if (fonts.isEmpty) return null;
    return state.copyWith(fonts: fonts);
  }
}

class RemoveFontsAction extends ReduxAction<AppState> {
  final FontModel model;

  RemoveFontsAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final removed = await ApiService().fontAPI.remove(model);
    final fonts = List.of(state.fonts, growable: true);
    fonts.remove(removed);
    return state.copyWith(fonts: fonts);
  }
}

class AddFontAction extends ReduxAction<AppState> {
  final FontModel _model;

  AddFontAction(this._model);

  @override
  Future<AppState?> reduce() async {
    final FontModel added = await ApiService().fontAPI.add(_model);
    final List<FontModel> fonts = List.of(state.fonts, growable: true);
    fonts.add(added);
    return state.copyWith(fonts: fonts, selectedFont: added);
  }
}

class UpdateFontAction extends ReduxAction<AppState> {
  final FontModel newEntry;

  UpdateFontAction(this.newEntry);

  @override
  Future<AppState?> reduce() async => state.copyWith(selectedFont: newEntry);
}

class FontDatabaseUpdate extends ReduxAction<AppState> {

  FontDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedFont == null) return null;
    final FontModel selected = state.selectedFont!;
    final FontModel dbModel = await ApiService().fontAPI.update(selected);
    final List<FontModel> models = List.of(state.fonts, growable: true);
    final int index = models.indexWhere((element) => element.id == selected.id);
    models.removeAt(index);
    models.insert(index, dbModel);
    return state.copyWith(fonts: models, selectedFont: dbModel);
  }
}
