import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:localstorage/localstorage.dart';
import 'package:stelaris_ui/api/state/app_state.dart';

class AppPersistor extends Persistor<AppState> {
  static const String appState = "appState";
  late LocalStorage storage;

  AppPersistor() {
    storage = LocalStorage(appState);
  }

  @override
  Future<void> deleteState() async {
    await storage.ready;
    await storage.deleteItem(appState);
  }

  @override
  Future<void> persistDifference(
      {required AppState? lastPersistedState,
      required AppState newState}) async {
    if (lastPersistedState != newState) {
      final Map<String, dynamic> json = newState.toJson();
      final String data = jsonEncode(json);
      await storage.ready;
      await storage.setItem(appState, data);
    }
  }

  @override
  Future<AppState> readState() async {
    await storage.ready;
    if (storage.getItem(appState) != null) {
      final String data = storage.getItem(appState) as String;
      final Map<String, dynamic> json =
          jsonDecode(data) as Map<String, dynamic>;
      return AppState.fromJson(json);
    }
    return const AppState();
  }
}
