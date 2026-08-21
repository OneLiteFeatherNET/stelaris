import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/api/converter/paginated_result_converter.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';

part 'app_state.g.dart';

part 'app_state.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class AppState with _$AppState {
  const factory AppState({
    @GenericPaginatedResultConverter<ItemModel>(
      fromJsonT: itemModelFromJson,
      toJsonT: itemModelToJson,
    )
    @Default(
      PaginatedResult<ItemModel>(
        items: [],
        totalItems: 0,
        totalPages: 0,
        currentPage: 1,
        pageSize: 0,
      ),
    )
    PaginatedResult<ItemModel> items,
    @Default(
      PaginatedResult<NotificationModel>(
        items: [],
        totalItems: 0,
        totalPages: 0,
        currentPage: 1,
        pageSize: 0,
      ),
    )
    @GenericPaginatedResultConverter<NotificationModel>(
      fromJsonT: notificationFromJson,
      toJsonT: notificationModelToJson,
    )
    PaginatedResult<NotificationModel> notifications,
    @Default(
      PaginatedResult<FontModel>(
        items: [],
        totalItems: 0,
        totalPages: 0,
        currentPage: 1,
        pageSize: 0,
      ),
    )
    @GenericPaginatedResultConverter(
      fromJsonT: fontFromJson,
      toJsonT: fontToJson,
    )
    PaginatedResult<FontModel> fonts,
    @GenericPaginatedResultConverter<AttributeModel>(
      fromJsonT: attributeFromJson,
      toJsonT: attributeToJson,
    )
    @Default(
      PaginatedResult<AttributeModel>(
        items: [],
        totalItems: 0,
        totalPages: 0,
        currentPage: 1,
        pageSize: 0,
      ),
    )
    PaginatedResult<AttributeModel> attributes,
    @GenericPaginatedResultConverter<SoundEventModel>(
      fromJsonT: soundEventFromJson,
      toJsonT: soundEventToJson,
    )
    @Default(
      PaginatedResult<SoundEventModel>(
        items: [],
        totalItems: 0,
        totalPages: 0,
        currentPage: 1,
        pageSize: 0,
      ),
    )
    PaginatedResult<SoundEventModel> soundEvents,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingAttributesMore,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingMoreItems,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingMoreNotifications,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingMoreFonts,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingMoreSoundEvents,
    @Default(false) bool isLoadingRelease,
    @Default(true) bool openNavigation,
    @Default(
      ThemeSettings(
        isDarkMode: false,
        primaryColor: Colors.blue,
        accentColor: Colors.blueAccent,
        fontScale: 1,
        useSystemTheme: true,
      ),
    )
    ThemeSettings themeSettings,
    @JsonKey(includeToJson: false) ItemModel? selectedItem,
    @JsonKey(includeToJson: false) NotificationModel? selectedNotification,
    @JsonKey(includeToJson: false) FontModel? selectedFont,
    @JsonKey(includeToJson: false) AttributeModel? selectedAttribute,
    @JsonKey(includeToJson: false) SoundEventModel? selectedSoundEvent,
    ReleaseModel? releaseModel,
    @Default(false) bool isLoadingBranches,
    List<String>? branches,
  }) = _AppState;

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);
}
