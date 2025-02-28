import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'theme_settings.g.dart';

@JsonSerializable()
class ThemeSettings {
  const ThemeSettings({
    required this.isDarkMode,
    required this.primaryColor,
    required this.accentColor,
    required this.fontScale,
    required this.useSystemTheme,
  });

  final bool isDarkMode;
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color primaryColor;
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color accentColor;
  final double fontScale;
  final bool useSystemTheme;

  static Color _colorFromJson(int value) => Color(value);
  static int _colorToJson(Color color) => color.value;

  factory ThemeSettings.fromJson(Map<String, dynamic> json) =>
      _$ThemeSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ThemeSettingsToJson(this);

  ThemeSettings copyWith({
    bool? isDarkMode,
    Color? primaryColor,
    Color? accentColor,
    double? fontScale,
    bool? useSystemTheme,
  }) {
    return ThemeSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      fontScale: fontScale ?? this.fontScale,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
    );
  }

  static ThemeSettings defaultSettings() {
    return ThemeSettings(
      isDarkMode: false,
      primaryColor: Colors.green[400] ?? Colors.green,
      accentColor: Colors.green[200] ?? Colors.green,
      fontScale: 1,
      useSystemTheme: true,
    );
  }

  ThemeSettings forThemeMode(bool isDark) {
    return copyWith(
      isDarkMode: isDark,
      primaryColor: isDark ? Colors.teal[400] ?? Colors.teal : Colors.green[400] ?? Colors.green,
      accentColor: isDark ? Colors.teal[800] ?? Colors.teal : Colors.green[200] ?? Colors.green,
    );
  }
}
