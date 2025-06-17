import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/state/app_state.dart';

/// The [UpdateNavigationAction] is a [ReduxAction] that toggles the navigation state in the [AppState] of the application.
/// The navigation state indicates if the [NavigationDrawer] is open or closed.
class UpdateNavigationAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    return state.copyWith(openNavigation: !state.openNavigation);
  }
}
