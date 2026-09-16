import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:localstorage/localstorage.dart';

import 'app_state.dart';

class AppPersistor extends Persistor<AppState> {
  static const String appState = 'appState';

  AppPersistor() {
    if (localStorage.getItem(appState) == null) {
      localStorage.setItem(appState, '{}');
    }
  }

  @override
  Future<void> deleteState() async => localStorage.clear();

  @override
  Future<void> persistDifference({
    required AppState? lastPersistedState,
    required AppState newState,
  }) async {
    if (lastPersistedState != newState) {
      try {
        final Map<String, dynamic> json = newState.toJson();
        final String data = jsonEncode(json);
        localStorage.setItem(appState, data);
      } catch (_) {}
    }
  }

  @override
  Future<AppState> readState() async {
    try {
      final raw = localStorage.getItem(appState);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return AppState.fromJson(decoded);
        }
      }
    } catch (_) {
      // If persisted state is malformed or incompatible, reset and fallback to default.
      try {
        localStorage.setItem(appState, '{}');
      } catch (_) {}
    }
    return const AppState();
  }
}
