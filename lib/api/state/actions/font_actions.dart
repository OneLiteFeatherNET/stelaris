import 'package:async_redux/async_redux.dart';

import '../../../util/default.dart';
import '../../api_service.dart';
import '../../model/font_model.dart';
import '../app_state.dart';

class UpdateFontAction extends ReduxAction<AppState> {
  final FontModel font;

  UpdateFontAction(this.font);

  @override
  Future<AppState?> reduce() async {
    return state.copyWith(fonts: [fontModel]);
  }
}

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
    final fonts = List.of(state.fonts, growable: true);
    fonts.remove(model);
    return state.copyWith(fonts: fonts);
  }
}