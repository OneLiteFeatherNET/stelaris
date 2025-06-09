// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThemeSettings _$ThemeSettingsFromJson(Map<String, dynamic> json) =>
    ThemeSettings(
      isDarkMode: json['isDarkMode'] as bool,
      primaryColor: ThemeSettings._colorFromJson(
        (json['primaryColor'] as num).toInt(),
      ),
      accentColor: ThemeSettings._colorFromJson(
        (json['accentColor'] as num).toInt(),
      ),
      fontScale: (json['fontScale'] as num).toDouble(),
      useSystemTheme: json['useSystemTheme'] as bool,
    );

Map<String, dynamic> _$ThemeSettingsToJson(ThemeSettings instance) =>
    <String, dynamic>{
      'isDarkMode': instance.isDarkMode,
      'primaryColor': ThemeSettings._colorToJson(instance.primaryColor),
      'accentColor': ThemeSettings._colorToJson(instance.accentColor),
      'fontScale': instance.fontScale,
      'useSystemTheme': instance.useSystemTheme,
    };
