import 'package:flutter/material.dart';
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

  /// Returns the default theme settings used when no user preference is found.
  static ThemeSettings defaultSettings() {
    return ThemeSettings(
      isDarkMode: false,
      primaryColor: Colors.green[400] ?? Colors.green,
      accentColor: Colors.green[200] ?? Colors.green,
      fontScale: 1,
      useSystemTheme: true,
    );
  }

  /// Creates a copy of the current settings adapted for the specified theme mode.
  ///
  /// Adjusts colors based on whether [isDark] is true.
  ThemeSettings forThemeMode(bool isDark) {
    return copyWith(
      isDarkMode: isDark,
      primaryColor: isDark
          ? Colors.teal[400] ?? Colors.teal
          : Colors.green[400] ?? Colors.green,
      accentColor: isDark
          ? Colors.teal[800] ?? Colors.teal
          : Colors.green[200] ?? Colors.green,
    );
  }
}
