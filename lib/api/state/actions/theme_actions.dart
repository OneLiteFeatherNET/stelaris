import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';

class UpdateThemeSettingsAction extends ReduxAction<AppState> {
  UpdateThemeSettingsAction(this.settings);

  final ThemeSettings settings;

  @override
  AppState reduce() => state.copyWith(themeSettings: settings);
}

class ToggleSystemThemeAction extends ReduxAction<AppState> {
  ToggleSystemThemeAction(this.systemIsDark);

  final bool systemIsDark;

  @override
  AppState reduce() {
    final currentSettings = state.themeSettings;
    final newSettings = currentSettings.copyWith(
      useSystemTheme: !currentSettings.useSystemTheme,
      // Seed isDarkMode with the live system brightness so that switching
      // "follow system" off doesn't snap back to a stale manual value.
      isDarkMode: systemIsDark,
    );
    return state.copyWith(themeSettings: newSettings);
  }
}

class ToggleDarkModeAction extends ReduxAction<AppState> {
  @override
  AppState reduce() {
    final currentSettings = state.themeSettings;
    final newSettings = currentSettings.copyWith(
      isDarkMode: !currentSettings.isDarkMode,
      useSystemTheme: false, // Disable system theme when manually toggling
    );
    return state.copyWith(themeSettings: newSettings);
  }
}

class UpdatePrimaryColorAction extends ReduxAction<AppState> {
  UpdatePrimaryColorAction(this.color);

  final Color color;

  @override
  AppState reduce() {
    final newSettings = state.themeSettings.copyWith(primaryColor: color);
    return state.copyWith(themeSettings: newSettings);
  }
}

class UpdateAccentColorAction extends ReduxAction<AppState> {
  UpdateAccentColorAction(this.color);

  final Color color;

  @override
  AppState reduce() {
    final newSettings = state.themeSettings.copyWith(accentColor: color);
    return state.copyWith(themeSettings: newSettings);
  }
}

class UpdateFontScaleAction extends ReduxAction<AppState> {
  UpdateFontScaleAction(this.scale);

  final double scale;

  @override
  AppState reduce() {
    final newSettings = state.themeSettings.copyWith(fontScale: scale);
    return state.copyWith(themeSettings: newSettings);
  }
}
