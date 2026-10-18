import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_settings.freezed.dart';
part 'theme_settings.g.dart';

/// Manages the visual theme settings for the application, including color schemes
/// and display preferences.
@freezed
abstract class ThemeSettings with _$ThemeSettings {
  const ThemeSettings._();

  /// Creates a configuration for the application theme.
  const factory ThemeSettings({
    required bool isDarkMode,
    @JsonKey(
      fromJson: ThemeSettings._colorFromJson,
      toJson: ThemeSettings._colorToJson,
    )
    required Color primaryColor,
    @JsonKey(
      fromJson: ThemeSettings._colorFromJson,
      toJson: ThemeSettings._colorToJson,
    )
    required Color accentColor,
    required double fontScale,
    required bool useSystemTheme,
  }) = _ThemeSettings;

  /// Creates a [ThemeSettings] instance from a JSON map.
  factory ThemeSettings.fromJson(Map<String, dynamic> json) =>
      _$ThemeSettingsFromJson(json);

  static Color _colorFromJson(int value) => Color(value);
  static int _colorToJson(Color color) => color.toARGB32();

  /// The theme mode the app shows: the platform's while [useSystemTheme] is
  /// on, otherwise the manual choice of [isDarkMode].
  ThemeMode get themeMode {
    if (useSystemTheme) return ThemeMode.system;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  /// Returns the default theme settings used when no user preference is
  /// found. The same as the default of `AppState.themeSettings`, a test
  /// keeps the two equal.
  static ThemeSettings defaultSettings() {
    return const ThemeSettings(
      isDarkMode: false,
      primaryColor: Colors.blue,
      accentColor: Colors.blueAccent,
      fontScale: 1,
      useSystemTheme: true,
    );
  }
}
