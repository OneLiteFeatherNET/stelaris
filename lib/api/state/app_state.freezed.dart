// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppState {

@GenericPaginatedResultConverter<ItemModel>(fromJsonT: itemModelFromJson, toJsonT: itemModelToJson) PaginatedResult<ItemModel> get items;@GenericPaginatedResultConverter<NotificationModel>(fromJsonT: notificationFromJson, toJsonT: notificationModelToJson) PaginatedResult<NotificationModel> get notifications;@GenericPaginatedResultConverter(fromJsonT: fontFromJson, toJsonT: fontToJson) PaginatedResult<FontModel> get fonts;@GenericPaginatedResultConverter<AttributeModel>(fromJsonT: attributeFromJson, toJsonT: attributeToJson) PaginatedResult<AttributeModel> get attributes;@JsonKey(includeToJson: false, includeFromJson: false) bool get isLoadingAttributesMore;@JsonKey(includeToJson: false, includeFromJson: false) bool get isLoadingMoreItems;@JsonKey(includeToJson: false, includeFromJson: false) bool get isLoadingMoreNotifications;@JsonKey(includeToJson: false, includeFromJson: false) bool get isLoadingMoreFonts; bool get openNavigation; ThemeSettings get themeSettings;@JsonKey(includeToJson: false) ItemModel? get selectedItem;@JsonKey(includeToJson: false) NotificationModel? get selectedNotification;@JsonKey(includeToJson: false) FontModel? get selectedFont;@JsonKey(includeToJson: false) AttributeModel? get selectedAttribute;
/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppStateCopyWith<AppState> get copyWith => _$AppStateCopyWithImpl<AppState>(this as AppState, _$identity);

  /// Serializes this AppState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppState&&(identical(other.items, items) || other.items == items)&&(identical(other.notifications, notifications) || other.notifications == notifications)&&(identical(other.fonts, fonts) || other.fonts == fonts)&&(identical(other.attributes, attributes) || other.attributes == attributes)&&(identical(other.isLoadingAttributesMore, isLoadingAttributesMore) || other.isLoadingAttributesMore == isLoadingAttributesMore)&&(identical(other.isLoadingMoreItems, isLoadingMoreItems) || other.isLoadingMoreItems == isLoadingMoreItems)&&(identical(other.isLoadingMoreNotifications, isLoadingMoreNotifications) || other.isLoadingMoreNotifications == isLoadingMoreNotifications)&&(identical(other.isLoadingMoreFonts, isLoadingMoreFonts) || other.isLoadingMoreFonts == isLoadingMoreFonts)&&(identical(other.openNavigation, openNavigation) || other.openNavigation == openNavigation)&&(identical(other.themeSettings, themeSettings) || other.themeSettings == themeSettings)&&(identical(other.selectedItem, selectedItem) || other.selectedItem == selectedItem)&&(identical(other.selectedNotification, selectedNotification) || other.selectedNotification == selectedNotification)&&(identical(other.selectedFont, selectedFont) || other.selectedFont == selectedFont)&&(identical(other.selectedAttribute, selectedAttribute) || other.selectedAttribute == selectedAttribute));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,items,notifications,fonts,attributes,isLoadingAttributesMore,isLoadingMoreItems,isLoadingMoreNotifications,isLoadingMoreFonts,openNavigation,themeSettings,selectedItem,selectedNotification,selectedFont,selectedAttribute);

@override
String toString() {
  return 'AppState(items: $items, notifications: $notifications, fonts: $fonts, attributes: $attributes, isLoadingAttributesMore: $isLoadingAttributesMore, isLoadingMoreItems: $isLoadingMoreItems, isLoadingMoreNotifications: $isLoadingMoreNotifications, isLoadingMoreFonts: $isLoadingMoreFonts, openNavigation: $openNavigation, themeSettings: $themeSettings, selectedItem: $selectedItem, selectedNotification: $selectedNotification, selectedFont: $selectedFont, selectedAttribute: $selectedAttribute)';
}


}

/// @nodoc
abstract mixin class $AppStateCopyWith<$Res>  {
  factory $AppStateCopyWith(AppState value, $Res Function(AppState) _then) = _$AppStateCopyWithImpl;
@useResult
$Res call({
@GenericPaginatedResultConverter<ItemModel>(fromJsonT: itemModelFromJson, toJsonT: itemModelToJson) PaginatedResult<ItemModel> items,@GenericPaginatedResultConverter<NotificationModel>(fromJsonT: notificationFromJson, toJsonT: notificationModelToJson) PaginatedResult<NotificationModel> notifications,@GenericPaginatedResultConverter(fromJsonT: fontFromJson, toJsonT: fontToJson) PaginatedResult<FontModel> fonts,@GenericPaginatedResultConverter<AttributeModel>(fromJsonT: attributeFromJson, toJsonT: attributeToJson) PaginatedResult<AttributeModel> attributes,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingAttributesMore,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingMoreItems,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingMoreNotifications,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingMoreFonts, bool openNavigation, ThemeSettings themeSettings,@JsonKey(includeToJson: false) ItemModel? selectedItem,@JsonKey(includeToJson: false) NotificationModel? selectedNotification,@JsonKey(includeToJson: false) FontModel? selectedFont,@JsonKey(includeToJson: false) AttributeModel? selectedAttribute
});


$ItemModelCopyWith<$Res>? get selectedItem;$NotificationModelCopyWith<$Res>? get selectedNotification;$FontModelCopyWith<$Res>? get selectedFont;$AttributeModelCopyWith<$Res>? get selectedAttribute;

}
/// @nodoc
class _$AppStateCopyWithImpl<$Res>
    implements $AppStateCopyWith<$Res> {
  _$AppStateCopyWithImpl(this._self, this._then);

  final AppState _self;
  final $Res Function(AppState) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? notifications = null,Object? fonts = null,Object? attributes = null,Object? isLoadingAttributesMore = null,Object? isLoadingMoreItems = null,Object? isLoadingMoreNotifications = null,Object? isLoadingMoreFonts = null,Object? openNavigation = null,Object? themeSettings = null,Object? selectedItem = freezed,Object? selectedNotification = freezed,Object? selectedFont = freezed,Object? selectedAttribute = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as PaginatedResult<ItemModel>,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as PaginatedResult<NotificationModel>,fonts: null == fonts ? _self.fonts : fonts // ignore: cast_nullable_to_non_nullable
as PaginatedResult<FontModel>,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as PaginatedResult<AttributeModel>,isLoadingAttributesMore: null == isLoadingAttributesMore ? _self.isLoadingAttributesMore : isLoadingAttributesMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreItems: null == isLoadingMoreItems ? _self.isLoadingMoreItems : isLoadingMoreItems // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreNotifications: null == isLoadingMoreNotifications ? _self.isLoadingMoreNotifications : isLoadingMoreNotifications // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreFonts: null == isLoadingMoreFonts ? _self.isLoadingMoreFonts : isLoadingMoreFonts // ignore: cast_nullable_to_non_nullable
as bool,openNavigation: null == openNavigation ? _self.openNavigation : openNavigation // ignore: cast_nullable_to_non_nullable
as bool,themeSettings: null == themeSettings ? _self.themeSettings : themeSettings // ignore: cast_nullable_to_non_nullable
as ThemeSettings,selectedItem: freezed == selectedItem ? _self.selectedItem : selectedItem // ignore: cast_nullable_to_non_nullable
as ItemModel?,selectedNotification: freezed == selectedNotification ? _self.selectedNotification : selectedNotification // ignore: cast_nullable_to_non_nullable
as NotificationModel?,selectedFont: freezed == selectedFont ? _self.selectedFont : selectedFont // ignore: cast_nullable_to_non_nullable
as FontModel?,selectedAttribute: freezed == selectedAttribute ? _self.selectedAttribute : selectedAttribute // ignore: cast_nullable_to_non_nullable
as AttributeModel?,
  ));
}
/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemModelCopyWith<$Res>? get selectedItem {
    if (_self.selectedItem == null) {
    return null;
  }

  return $ItemModelCopyWith<$Res>(_self.selectedItem!, (value) {
    return _then(_self.copyWith(selectedItem: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationModelCopyWith<$Res>? get selectedNotification {
    if (_self.selectedNotification == null) {
    return null;
  }

  return $NotificationModelCopyWith<$Res>(_self.selectedNotification!, (value) {
    return _then(_self.copyWith(selectedNotification: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FontModelCopyWith<$Res>? get selectedFont {
    if (_self.selectedFont == null) {
    return null;
  }

  return $FontModelCopyWith<$Res>(_self.selectedFont!, (value) {
    return _then(_self.copyWith(selectedFont: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttributeModelCopyWith<$Res>? get selectedAttribute {
    if (_self.selectedAttribute == null) {
    return null;
  }

  return $AttributeModelCopyWith<$Res>(_self.selectedAttribute!, (value) {
    return _then(_self.copyWith(selectedAttribute: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppState].
extension AppStatePatterns on AppState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppState value)  $default,){
final _that = this;
switch (_that) {
case _AppState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppState value)?  $default,){
final _that = this;
switch (_that) {
case _AppState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@GenericPaginatedResultConverter<ItemModel>(fromJsonT: itemModelFromJson, toJsonT: itemModelToJson)  PaginatedResult<ItemModel> items, @GenericPaginatedResultConverter<NotificationModel>(fromJsonT: notificationFromJson, toJsonT: notificationModelToJson)  PaginatedResult<NotificationModel> notifications, @GenericPaginatedResultConverter(fromJsonT: fontFromJson, toJsonT: fontToJson)  PaginatedResult<FontModel> fonts, @GenericPaginatedResultConverter<AttributeModel>(fromJsonT: attributeFromJson, toJsonT: attributeToJson)  PaginatedResult<AttributeModel> attributes, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingAttributesMore, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreItems, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreNotifications, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreFonts,  bool openNavigation,  ThemeSettings themeSettings, @JsonKey(includeToJson: false)  ItemModel? selectedItem, @JsonKey(includeToJson: false)  NotificationModel? selectedNotification, @JsonKey(includeToJson: false)  FontModel? selectedFont, @JsonKey(includeToJson: false)  AttributeModel? selectedAttribute)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppState() when $default != null:
return $default(_that.items,_that.notifications,_that.fonts,_that.attributes,_that.isLoadingAttributesMore,_that.isLoadingMoreItems,_that.isLoadingMoreNotifications,_that.isLoadingMoreFonts,_that.openNavigation,_that.themeSettings,_that.selectedItem,_that.selectedNotification,_that.selectedFont,_that.selectedAttribute);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@GenericPaginatedResultConverter<ItemModel>(fromJsonT: itemModelFromJson, toJsonT: itemModelToJson)  PaginatedResult<ItemModel> items, @GenericPaginatedResultConverter<NotificationModel>(fromJsonT: notificationFromJson, toJsonT: notificationModelToJson)  PaginatedResult<NotificationModel> notifications, @GenericPaginatedResultConverter(fromJsonT: fontFromJson, toJsonT: fontToJson)  PaginatedResult<FontModel> fonts, @GenericPaginatedResultConverter<AttributeModel>(fromJsonT: attributeFromJson, toJsonT: attributeToJson)  PaginatedResult<AttributeModel> attributes, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingAttributesMore, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreItems, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreNotifications, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreFonts,  bool openNavigation,  ThemeSettings themeSettings, @JsonKey(includeToJson: false)  ItemModel? selectedItem, @JsonKey(includeToJson: false)  NotificationModel? selectedNotification, @JsonKey(includeToJson: false)  FontModel? selectedFont, @JsonKey(includeToJson: false)  AttributeModel? selectedAttribute)  $default,) {final _that = this;
switch (_that) {
case _AppState():
return $default(_that.items,_that.notifications,_that.fonts,_that.attributes,_that.isLoadingAttributesMore,_that.isLoadingMoreItems,_that.isLoadingMoreNotifications,_that.isLoadingMoreFonts,_that.openNavigation,_that.themeSettings,_that.selectedItem,_that.selectedNotification,_that.selectedFont,_that.selectedAttribute);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@GenericPaginatedResultConverter<ItemModel>(fromJsonT: itemModelFromJson, toJsonT: itemModelToJson)  PaginatedResult<ItemModel> items, @GenericPaginatedResultConverter<NotificationModel>(fromJsonT: notificationFromJson, toJsonT: notificationModelToJson)  PaginatedResult<NotificationModel> notifications, @GenericPaginatedResultConverter(fromJsonT: fontFromJson, toJsonT: fontToJson)  PaginatedResult<FontModel> fonts, @GenericPaginatedResultConverter<AttributeModel>(fromJsonT: attributeFromJson, toJsonT: attributeToJson)  PaginatedResult<AttributeModel> attributes, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingAttributesMore, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreItems, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreNotifications, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreFonts,  bool openNavigation,  ThemeSettings themeSettings, @JsonKey(includeToJson: false)  ItemModel? selectedItem, @JsonKey(includeToJson: false)  NotificationModel? selectedNotification, @JsonKey(includeToJson: false)  FontModel? selectedFont, @JsonKey(includeToJson: false)  AttributeModel? selectedAttribute)?  $default,) {final _that = this;
switch (_that) {
case _AppState() when $default != null:
return $default(_that.items,_that.notifications,_that.fonts,_that.attributes,_that.isLoadingAttributesMore,_that.isLoadingMoreItems,_that.isLoadingMoreNotifications,_that.isLoadingMoreFonts,_that.openNavigation,_that.themeSettings,_that.selectedItem,_that.selectedNotification,_that.selectedFont,_that.selectedAttribute);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppState implements AppState {
  const _AppState({@GenericPaginatedResultConverter<ItemModel>(fromJsonT: itemModelFromJson, toJsonT: itemModelToJson) this.items = const PaginatedResult<ItemModel>(items: [], totalItems: 0, totalPages: 0, currentPage: 1, pageSize: 0), @GenericPaginatedResultConverter<NotificationModel>(fromJsonT: notificationFromJson, toJsonT: notificationModelToJson) this.notifications = const PaginatedResult<NotificationModel>(items: [], totalItems: 0, totalPages: 0, currentPage: 1, pageSize: 0), @GenericPaginatedResultConverter(fromJsonT: fontFromJson, toJsonT: fontToJson) this.fonts = const PaginatedResult<FontModel>(items: [], totalItems: 0, totalPages: 0, currentPage: 1, pageSize: 0), @GenericPaginatedResultConverter<AttributeModel>(fromJsonT: attributeFromJson, toJsonT: attributeToJson) this.attributes = const PaginatedResult<AttributeModel>(items: [], totalItems: 0, totalPages: 0, currentPage: 1, pageSize: 0), @JsonKey(includeToJson: false, includeFromJson: false) this.isLoadingAttributesMore = false, @JsonKey(includeToJson: false, includeFromJson: false) this.isLoadingMoreItems = false, @JsonKey(includeToJson: false, includeFromJson: false) this.isLoadingMoreNotifications = false, @JsonKey(includeToJson: false, includeFromJson: false) this.isLoadingMoreFonts = false, this.openNavigation = true, this.themeSettings = const ThemeSettings(isDarkMode: false, primaryColor: Colors.blue, accentColor: Colors.blueAccent, fontScale: 1, useSystemTheme: true), @JsonKey(includeToJson: false) this.selectedItem, @JsonKey(includeToJson: false) this.selectedNotification, @JsonKey(includeToJson: false) this.selectedFont, @JsonKey(includeToJson: false) this.selectedAttribute});
  factory _AppState.fromJson(Map<String, dynamic> json) => _$AppStateFromJson(json);

@override@JsonKey()@GenericPaginatedResultConverter<ItemModel>(fromJsonT: itemModelFromJson, toJsonT: itemModelToJson) final  PaginatedResult<ItemModel> items;
@override@JsonKey()@GenericPaginatedResultConverter<NotificationModel>(fromJsonT: notificationFromJson, toJsonT: notificationModelToJson) final  PaginatedResult<NotificationModel> notifications;
@override@JsonKey()@GenericPaginatedResultConverter(fromJsonT: fontFromJson, toJsonT: fontToJson) final  PaginatedResult<FontModel> fonts;
@override@JsonKey()@GenericPaginatedResultConverter<AttributeModel>(fromJsonT: attributeFromJson, toJsonT: attributeToJson) final  PaginatedResult<AttributeModel> attributes;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  bool isLoadingAttributesMore;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  bool isLoadingMoreItems;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  bool isLoadingMoreNotifications;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  bool isLoadingMoreFonts;
@override@JsonKey() final  bool openNavigation;
@override@JsonKey() final  ThemeSettings themeSettings;
@override@JsonKey(includeToJson: false) final  ItemModel? selectedItem;
@override@JsonKey(includeToJson: false) final  NotificationModel? selectedNotification;
@override@JsonKey(includeToJson: false) final  FontModel? selectedFont;
@override@JsonKey(includeToJson: false) final  AttributeModel? selectedAttribute;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppStateCopyWith<_AppState> get copyWith => __$AppStateCopyWithImpl<_AppState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppState&&(identical(other.items, items) || other.items == items)&&(identical(other.notifications, notifications) || other.notifications == notifications)&&(identical(other.fonts, fonts) || other.fonts == fonts)&&(identical(other.attributes, attributes) || other.attributes == attributes)&&(identical(other.isLoadingAttributesMore, isLoadingAttributesMore) || other.isLoadingAttributesMore == isLoadingAttributesMore)&&(identical(other.isLoadingMoreItems, isLoadingMoreItems) || other.isLoadingMoreItems == isLoadingMoreItems)&&(identical(other.isLoadingMoreNotifications, isLoadingMoreNotifications) || other.isLoadingMoreNotifications == isLoadingMoreNotifications)&&(identical(other.isLoadingMoreFonts, isLoadingMoreFonts) || other.isLoadingMoreFonts == isLoadingMoreFonts)&&(identical(other.openNavigation, openNavigation) || other.openNavigation == openNavigation)&&(identical(other.themeSettings, themeSettings) || other.themeSettings == themeSettings)&&(identical(other.selectedItem, selectedItem) || other.selectedItem == selectedItem)&&(identical(other.selectedNotification, selectedNotification) || other.selectedNotification == selectedNotification)&&(identical(other.selectedFont, selectedFont) || other.selectedFont == selectedFont)&&(identical(other.selectedAttribute, selectedAttribute) || other.selectedAttribute == selectedAttribute));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,items,notifications,fonts,attributes,isLoadingAttributesMore,isLoadingMoreItems,isLoadingMoreNotifications,isLoadingMoreFonts,openNavigation,themeSettings,selectedItem,selectedNotification,selectedFont,selectedAttribute);

@override
String toString() {
  return 'AppState(items: $items, notifications: $notifications, fonts: $fonts, attributes: $attributes, isLoadingAttributesMore: $isLoadingAttributesMore, isLoadingMoreItems: $isLoadingMoreItems, isLoadingMoreNotifications: $isLoadingMoreNotifications, isLoadingMoreFonts: $isLoadingMoreFonts, openNavigation: $openNavigation, themeSettings: $themeSettings, selectedItem: $selectedItem, selectedNotification: $selectedNotification, selectedFont: $selectedFont, selectedAttribute: $selectedAttribute)';
}


}

/// @nodoc
abstract mixin class _$AppStateCopyWith<$Res> implements $AppStateCopyWith<$Res> {
  factory _$AppStateCopyWith(_AppState value, $Res Function(_AppState) _then) = __$AppStateCopyWithImpl;
@override @useResult
$Res call({
@GenericPaginatedResultConverter<ItemModel>(fromJsonT: itemModelFromJson, toJsonT: itemModelToJson) PaginatedResult<ItemModel> items,@GenericPaginatedResultConverter<NotificationModel>(fromJsonT: notificationFromJson, toJsonT: notificationModelToJson) PaginatedResult<NotificationModel> notifications,@GenericPaginatedResultConverter(fromJsonT: fontFromJson, toJsonT: fontToJson) PaginatedResult<FontModel> fonts,@GenericPaginatedResultConverter<AttributeModel>(fromJsonT: attributeFromJson, toJsonT: attributeToJson) PaginatedResult<AttributeModel> attributes,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingAttributesMore,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingMoreItems,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingMoreNotifications,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingMoreFonts, bool openNavigation, ThemeSettings themeSettings,@JsonKey(includeToJson: false) ItemModel? selectedItem,@JsonKey(includeToJson: false) NotificationModel? selectedNotification,@JsonKey(includeToJson: false) FontModel? selectedFont,@JsonKey(includeToJson: false) AttributeModel? selectedAttribute
});


@override $ItemModelCopyWith<$Res>? get selectedItem;@override $NotificationModelCopyWith<$Res>? get selectedNotification;@override $FontModelCopyWith<$Res>? get selectedFont;@override $AttributeModelCopyWith<$Res>? get selectedAttribute;

}
/// @nodoc
class __$AppStateCopyWithImpl<$Res>
    implements _$AppStateCopyWith<$Res> {
  __$AppStateCopyWithImpl(this._self, this._then);

  final _AppState _self;
  final $Res Function(_AppState) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? notifications = null,Object? fonts = null,Object? attributes = null,Object? isLoadingAttributesMore = null,Object? isLoadingMoreItems = null,Object? isLoadingMoreNotifications = null,Object? isLoadingMoreFonts = null,Object? openNavigation = null,Object? themeSettings = null,Object? selectedItem = freezed,Object? selectedNotification = freezed,Object? selectedFont = freezed,Object? selectedAttribute = freezed,}) {
  return _then(_AppState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as PaginatedResult<ItemModel>,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as PaginatedResult<NotificationModel>,fonts: null == fonts ? _self.fonts : fonts // ignore: cast_nullable_to_non_nullable
as PaginatedResult<FontModel>,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as PaginatedResult<AttributeModel>,isLoadingAttributesMore: null == isLoadingAttributesMore ? _self.isLoadingAttributesMore : isLoadingAttributesMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreItems: null == isLoadingMoreItems ? _self.isLoadingMoreItems : isLoadingMoreItems // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreNotifications: null == isLoadingMoreNotifications ? _self.isLoadingMoreNotifications : isLoadingMoreNotifications // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreFonts: null == isLoadingMoreFonts ? _self.isLoadingMoreFonts : isLoadingMoreFonts // ignore: cast_nullable_to_non_nullable
as bool,openNavigation: null == openNavigation ? _self.openNavigation : openNavigation // ignore: cast_nullable_to_non_nullable
as bool,themeSettings: null == themeSettings ? _self.themeSettings : themeSettings // ignore: cast_nullable_to_non_nullable
as ThemeSettings,selectedItem: freezed == selectedItem ? _self.selectedItem : selectedItem // ignore: cast_nullable_to_non_nullable
as ItemModel?,selectedNotification: freezed == selectedNotification ? _self.selectedNotification : selectedNotification // ignore: cast_nullable_to_non_nullable
as NotificationModel?,selectedFont: freezed == selectedFont ? _self.selectedFont : selectedFont // ignore: cast_nullable_to_non_nullable
as FontModel?,selectedAttribute: freezed == selectedAttribute ? _self.selectedAttribute : selectedAttribute // ignore: cast_nullable_to_non_nullable
as AttributeModel?,
  ));
}

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemModelCopyWith<$Res>? get selectedItem {
    if (_self.selectedItem == null) {
    return null;
  }

  return $ItemModelCopyWith<$Res>(_self.selectedItem!, (value) {
    return _then(_self.copyWith(selectedItem: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationModelCopyWith<$Res>? get selectedNotification {
    if (_self.selectedNotification == null) {
    return null;
  }

  return $NotificationModelCopyWith<$Res>(_self.selectedNotification!, (value) {
    return _then(_self.copyWith(selectedNotification: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FontModelCopyWith<$Res>? get selectedFont {
    if (_self.selectedFont == null) {
    return null;
  }

  return $FontModelCopyWith<$Res>(_self.selectedFont!, (value) {
    return _then(_self.copyWith(selectedFont: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttributeModelCopyWith<$Res>? get selectedAttribute {
    if (_self.selectedAttribute == null) {
    return null;
  }

  return $AttributeModelCopyWith<$Res>(_self.selectedAttribute!, (value) {
    return _then(_self.copyWith(selectedAttribute: value));
  });
}
}

// dart format on
