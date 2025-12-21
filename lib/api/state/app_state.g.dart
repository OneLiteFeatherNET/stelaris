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
  notifications: json['notifications'] == null
      ? const PaginatedResult<NotificationModel>(
          items: [],
          totalItems: 0,
          totalPages: 0,
          currentPage: 1,
          pageSize: 0,
        )
      : PaginatedResult<NotificationModel>.fromJson(
          json['notifications'] as Map<String, dynamic>,
          (value) => NotificationModel.fromJson(value as Map<String, dynamic>),
        ),
  fonts: json['fonts'] == null
      ? const PaginatedResult<FontModel>(
          items: [],
          totalItems: 0,
          totalPages: 0,
          currentPage: 1,
          pageSize: 0,
        )
      : PaginatedResult<FontModel>.fromJson(
          json['fonts'] as Map<String, dynamic>,
          (value) => FontModel.fromJson(value as Map<String, dynamic>),
        ),
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
  soundEvents: json['soundEvents'] == null
      ? const PaginatedResult<SoundEventModel>(
          items: [],
          totalItems: 0,
          totalPages: 0,
          currentPage: 1,
          pageSize: 0,
        )
      : PaginatedResult<SoundEventModel>.fromJson(
          json['soundEvents'] as Map<String, dynamic>,
          (value) => SoundEventModel.fromJson(value as Map<String, dynamic>),
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
  selectedSoundEvent: json['selectedSoundEvent'] == null
      ? null
      : SoundEventModel.fromJson(
          json['selectedSoundEvent'] as Map<String, dynamic>,
        ),
  releaseModel: json['releaseModel'] == null
      ? null
      : ReleaseModel.fromJson(json['releaseModel'] as Map<String, dynamic>),
  branches:
      (json['branches'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$AppStateToJson(_AppState instance) => <String, dynamic>{
  'items': instance.items.toJson((value) => value),
  'notifications': instance.notifications.toJson((value) => value),
  'fonts': instance.fonts.toJson((value) => value),
  'attributes': instance.attributes.toJson((value) => value),
  'soundEvents': instance.soundEvents.toJson((value) => value),
  'openNavigation': instance.openNavigation,
  'themeSettings': instance.themeSettings,
  'releaseModel': instance.releaseModel,
  'branches': instance.branches,
};
