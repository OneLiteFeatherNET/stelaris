// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppState _$AppStateFromJson(Map<String, dynamic> json) => _AppState(
  items: json['items'] == null
      ? const PaginatedResult<ItemModel>(
          items: [],
          totalItems: 0,
          totalPages: 0,
          currentPage: 1,
          pageSize: 0,
        )
      : PaginatedResult<ItemModel>.fromJson(
          json['items'] as Map<String, dynamic>,
          (value) => ItemModel.fromJson(value as Map<String, dynamic>),
        ),
  notifications:
      (json['notifications'] as List<dynamic>?)
          ?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  fonts:
      (json['fonts'] as List<dynamic>?)
          ?.map((e) => FontModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  attributes: json['attributes'] == null
      ? const PaginatedResult<AttributeModel>(
          items: [],
          totalItems: 0,
          totalPages: 0,
          currentPage: 1,
          pageSize: 0,
        )
      : PaginatedResult<AttributeModel>.fromJson(
          json['attributes'] as Map<String, dynamic>,
          (value) => AttributeModel.fromJson(value as Map<String, dynamic>),
        ),
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
  selectedItem: json['selectedItem'] == null
      ? null
      : ItemModel.fromJson(json['selectedItem'] as Map<String, dynamic>),
  selectedNotification: json['selectedNotification'] == null
      ? null
      : NotificationModel.fromJson(
          json['selectedNotification'] as Map<String, dynamic>,
        ),
  selectedFont: json['selectedFont'] == null
      ? null
      : FontModel.fromJson(json['selectedFont'] as Map<String, dynamic>),
  selectedAttribute: json['selectedAttribute'] == null
      ? null
      : AttributeModel.fromJson(
          json['selectedAttribute'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$AppStateToJson(_AppState instance) => <String, dynamic>{
  'items': instance.items.toJson((value) => value),
  'notifications': instance.notifications,
  'fonts': instance.fonts,
  'attributes': instance.attributes.toJson((value) => value),
  'openNavigation': instance.openNavigation,
  'themeSettings': instance.themeSettings,
};
