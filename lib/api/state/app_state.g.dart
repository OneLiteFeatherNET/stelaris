// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppState _$AppStateFromJson(Map<String, dynamic> json) => _AppState(
  openNavigation: json['openNavigation'] as bool? ?? true,
  themeSettings: json['themeSettings'] == null
      ? const ThemeSettings(
          isDarkMode: false,
          primaryColor: Colors.blue,
          accentColor: Colors.blueAccent,
          fontScale: 1,
          useSystemTheme: true,
        )
      : ThemeSettings.fromJson(json['themeSettings'] as Map<String, dynamic>),
  projects:
      (json['projects'] as List<dynamic>?)
          ?.map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$AppStateToJson(_AppState instance) => <String, dynamic>{
  'openNavigation': instance.openNavigation,
  'themeSettings': instance.themeSettings,
  'projects': instance.projects,
};
