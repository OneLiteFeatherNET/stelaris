import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:localstorage/localstorage.dart';

import 'app_state.dart';

class AppPersistor extends Persistor<AppState> {
  static const String appState = 'appState';
  late String storage;

  AppPersistor() {
    if (localStorage.getItem(appState) == null) {
      localStorage.setItem(appState, '{}');
    }
    storage = localStorage.getItem(appState)!;
  }

  @override
  Future<void> deleteState() async => localStorage.clear();

  @override
  Future<void> persistDifference({
    required AppState? lastPersistedState,
    required AppState newState,
  }) async {
    if (lastPersistedState != newState) {
      final Map<String, dynamic> json = newState.toJson();
      final String data = jsonEncode(json);
      localStorage.setItem(appState, data);
    }
  }

  @override
  Future<AppState> readState() async {
    if (localStorage.getItem(appState) != null) {
      final String data = localStorage.getItem(appState) as String;
      final Map<String, dynamic> json =
          jsonDecode(data) as Map<String, dynamic>;
      return AppState.fromJson(json);
    }
    return const AppState();
  }
}
