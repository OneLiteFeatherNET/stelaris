import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/state/app_state.dart';

class UpdateNavigationAction extends ReduxAction<AppState> {

  @override
  Future<AppState> reduce() async {
    return state.copyWith(openNavigation: !state.openNavigation);
  }
}

class ChangeThemeStateAction extends ReduxAction<AppState> {

  @override
  Future<AppState> reduce() async {
    return state.copyWith(nightMode: !state.nightMode);
  }
}
