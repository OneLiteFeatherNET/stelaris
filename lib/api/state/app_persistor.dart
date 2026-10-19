import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:localstorage/localstorage.dart';

import 'app_state.dart';

class AppPersistor extends Persistor<AppState> {
  static const String appState = 'appState';

  /// What was last written to or read from storage.
  ///
  /// The store hands every new state to [persistDifference], and nearly all of
  /// them only differ in caches and loading flags that `toJson` leaves out.
  /// Comparing the encoded form instead of the whole state skips those writes
  /// without keeping a second list of which fields are persisted.
  String? _lastWritten;

  AppPersistor() {
    if (localStorage.getItem(appState) == null) {
      localStorage.setItem(appState, '{}');
    }
  }

  /// Removes only this app's entry: the session store shares the origin's
  /// localStorage, and clearing all of it would sign the user out as well.
  @override
  Future<void> deleteState() async {
    localStorage.removeItem(appState);
    _lastWritten = null;
  }

  @override
  Future<void> persistDifference({
    required AppState? lastPersistedState,
    required AppState newState,
  }) async {
    if (lastPersistedState == newState) {
      return;
    }
    try {
      final String data = jsonEncode(newState.toJson());
      if (data == _lastWritten) {
        return;
      }
      localStorage.setItem(appState, data);
      _lastWritten = data;
    } catch (_) {}
  }

  @override
  Future<AppState> readState() async {
    try {
      final raw = localStorage.getItem(appState);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final AppState state = AppState.fromJson(decoded);
          _lastWritten = raw;
          return state;
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
