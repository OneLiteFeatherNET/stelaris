import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';

import '../app_presistor.dart';

class LoadThemeSettingsAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    final persistor = AppPersistor();
    final newState = await persistor.readState();
    return newState;
  }
}

class UpdateThemeSettingsAction extends ReduxAction<AppState> {
  UpdateThemeSettingsAction(this.settings);

  final ThemeSettings settings;

  @override
  Future<AppState> reduce() async {
    final persistor = AppPersistor();
    final newState = state.copyWith(themeSettings: settings);
    await persistor.persistDifference(lastPersistedState: state, newState: newState);
    return newState;
  }
}

class ToggleSystemThemeAction extends ReduxAction<AppState> {
  ToggleSystemThemeAction(this.systemIsDark);

  final bool systemIsDark;

  @override
  Future<AppState> reduce() async {
    final currentSettings = state.themeSettings;
    final newSettings = currentSettings.copyWith(
      useSystemTheme: !currentSettings.useSystemTheme,
    );
    
    dispatch(UpdateThemeSettingsAction(newSettings));
    return state.copyWith(themeSettings: newSettings);
  }
}

class ToggleDarkModeAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    final currentSettings = state.themeSettings;
    final newSettings = currentSettings.copyWith(
      isDarkMode: !currentSettings.isDarkMode,
      useSystemTheme: false, // Disable system theme when manually toggling
    );
    
    dispatch(UpdateThemeSettingsAction(newSettings));
    return state.copyWith(themeSettings: newSettings);
  }
}

class UpdatePrimaryColorAction extends ReduxAction<AppState> {
  UpdatePrimaryColorAction(this.color);

  final Color color;

  @override
  Future<AppState> reduce() async {
    final currentSettings = state.themeSettings;
    final newSettings = currentSettings.copyWith(primaryColor: color);
    
    dispatch(UpdateThemeSettingsAction(newSettings));
    return state.copyWith(themeSettings: newSettings);
  }
}

class UpdateAccentColorAction extends ReduxAction<AppState> {
  UpdateAccentColorAction(this.color);

  final Color color;

  @override
  Future<AppState> reduce() async {
    final currentSettings = state.themeSettings;
    final newSettings = currentSettings.copyWith(accentColor: color);
    
    dispatch(UpdateThemeSettingsAction(newSettings));
    return state.copyWith(themeSettings: newSettings);
  }
}

class UpdateFontScaleAction extends ReduxAction<AppState> {
  UpdateFontScaleAction(this.scale);

  final double scale;

  @override
  Future<AppState> reduce() async {
    final currentSettings = state.themeSettings;
    final newSettings = currentSettings.copyWith(fontScale: scale);
    
    dispatch(UpdateThemeSettingsAction(newSettings));
    return state.copyWith(themeSettings: newSettings);
  }
}
