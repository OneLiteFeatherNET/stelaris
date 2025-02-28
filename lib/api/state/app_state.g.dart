// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppStateImpl _$$AppStateImplFromJson(Map<String, dynamic> json) =>
    _$AppStateImpl(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map(
                  (e) => NotificationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fonts: (json['fonts'] as List<dynamic>?)
              ?.map((e) => FontModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((e) => AttributeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AttributeModel>[],
      openNavigation: json['openNavigation'] as bool? ?? true,
      themeSettings: json['themeSettings'] == null
          ? const ThemeSettings(
              isDarkMode: false,
              primaryColor: Colors.blue,
              accentColor: Colors.blueAccent,
              fontScale: 1,
              useSystemTheme: true)
          : ThemeSettings.fromJson(
              json['themeSettings'] as Map<String, dynamic>),
      selectedItem: json['selectedItem'] == null
          ? null
          : ItemModel.fromJson(json['selectedItem'] as Map<String, dynamic>),
      selectedNotification: json['selectedNotification'] == null
          ? null
          : NotificationModel.fromJson(
              json['selectedNotification'] as Map<String, dynamic>),
      selectedFont: json['selectedFont'] == null
          ? null
          : FontModel.fromJson(json['selectedFont'] as Map<String, dynamic>),
      selectedAttribute: json['selectedAttribute'] == null
          ? null
          : AttributeModel.fromJson(
              json['selectedAttribute'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AppStateImplToJson(_$AppStateImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'notifications': instance.notifications,
      'fonts': instance.fonts,
      'attributes': instance.attributes,
      'openNavigation': instance.openNavigation,
      'themeSettings': instance.themeSettings,
    };
