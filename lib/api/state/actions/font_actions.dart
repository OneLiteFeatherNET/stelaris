import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/api_service.dart';

import '../../model/font_model.dart';
import '../app_state.dart';

class InitFontAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    var fonts = await ApiService().fontAPI.getAllFonts();
    return state.copyWith(fonts: fonts);
  }

  InitFontAction();
}

class RemoveFontsAction extends ReduxAction<AppState> {

  final FontModel model;

  RemoveFontsAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().fontAPI.remove(model);
    final fonts = List.of(state.fonts, growable: true);
    fonts.remove(model);
    return state.copyWith(fonts: fonts);
  }
}

class AddFontAction extends ReduxAction<AppState> {

  final FontModel _model;

  AddFontAction(this._model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().fontAPI.addFont(_model);
    var fonts = await ApiService().fontAPI.getAllFonts();
    return state.copyWith(fonts: fonts);
  }
}


class UpdateFontAction extends ReduxAction<AppState> {
  final FontModel oldEntry;
  final FontModel newEntry;

  UpdateFontAction(this.oldEntry, this.newEntry);

  @override
  Future<AppState?> reduce() async {
    final items = List.of(state.fonts, growable: true);
    items.removeAt(items.indexWhere((element) => element.id == oldEntry.id));
    items.add(newEntry);
    return state.copyWith(fonts: items);
  }
}