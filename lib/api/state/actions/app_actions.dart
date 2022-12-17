import 'package:async_redux/async_redux.dart';

import '../app_state.dart';

class UpdateNavigationAction extends ReduxAction<AppState> {
  final bool openNavigation;

  UpdateNavigationAction(this.openNavigation);

  @override
  Future<AppState?> reduce() async {
    return state.copyWith(openNavigation: openNavigation);
  }
}
