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

/// Sets the theme mode through the stored fields. System keeps `isDarkMode`,
/// so the manual choice survives a round trip.
class SetThemeModeAction extends ReduxAction<AppState> {
  SetThemeModeAction(this.mode);

  final ThemeMode mode;

  @override
  AppState reduce() {
    final currentSettings = state.themeSettings;
    final newSettings = switch (mode) {
      ThemeMode.system => currentSettings.copyWith(useSystemTheme: true),
      ThemeMode.light => currentSettings.copyWith(
        useSystemTheme: false,
        isDarkMode: false,
      ),
      ThemeMode.dark => currentSettings.copyWith(
        useSystemTheme: false,
        isDarkMode: true,
      ),
    };
    return state.copyWith(themeSettings: newSettings);
  }
}

/// Restores the theme mode and the colors, but not the font scale.
class ResetAppearanceSettingsAction extends ReduxAction<AppState> {
  @override
  AppState reduce() {
    final defaults = ThemeSettings.defaultSettings();
    final newSettings = state.themeSettings.copyWith(
      useSystemTheme: defaults.useSystemTheme,
      isDarkMode: defaults.isDarkMode,
      primaryColor: defaults.primaryColor,
      accentColor: defaults.accentColor,
    );
    return state.copyWith(themeSettings: newSettings);
  }
}

/// Restores the font scale and nothing else.
class ResetFontScaleAction extends ReduxAction<AppState> {
  @override
  AppState reduce() {
    final newSettings = state.themeSettings.copyWith(
      fontScale: ThemeSettings.defaultSettings().fontScale,
    );
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
