// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
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

 List<ItemModel> get items; List<NotificationModel> get notifications; List<FontModel> get fonts; List<AttributeModel> get attributes; List<SoundEventModel> get soundEvents; bool get openNavigation; ThemeSettings get themeSettings;@JsonKey(includeToJson: false) ItemModel? get selectedItem;@JsonKey(includeToJson: false) NotificationModel? get selectedNotification;@JsonKey(includeToJson: false) FontModel? get selectedFont;@JsonKey(includeToJson: false) AttributeModel? get selectedAttribute;@JsonKey(includeToJson: false) SoundEventModel? get selectedSoundEvent;
/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppStateCopyWith<AppState> get copyWith => _$AppStateCopyWithImpl<AppState>(this as AppState, _$identity);

  /// Serializes this AppState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppState&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.notifications, notifications)&&const DeepCollectionEquality().equals(other.fonts, fonts)&&const DeepCollectionEquality().equals(other.attributes, attributes)&&const DeepCollectionEquality().equals(other.soundEvents, soundEvents)&&(identical(other.openNavigation, openNavigation) || other.openNavigation == openNavigation)&&(identical(other.themeSettings, themeSettings) || other.themeSettings == themeSettings)&&(identical(other.selectedItem, selectedItem) || other.selectedItem == selectedItem)&&(identical(other.selectedNotification, selectedNotification) || other.selectedNotification == selectedNotification)&&(identical(other.selectedFont, selectedFont) || other.selectedFont == selectedFont)&&(identical(other.selectedAttribute, selectedAttribute) || other.selectedAttribute == selectedAttribute)&&(identical(other.selectedSoundEvent, selectedSoundEvent) || other.selectedSoundEvent == selectedSoundEvent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(notifications),const DeepCollectionEquality().hash(fonts),const DeepCollectionEquality().hash(attributes),const DeepCollectionEquality().hash(soundEvents),openNavigation,themeSettings,selectedItem,selectedNotification,selectedFont,selectedAttribute,selectedSoundEvent);

@override
String toString() {
  return 'AppState(items: $items, notifications: $notifications, fonts: $fonts, attributes: $attributes, soundEvents: $soundEvents, openNavigation: $openNavigation, themeSettings: $themeSettings, selectedItem: $selectedItem, selectedNotification: $selectedNotification, selectedFont: $selectedFont, selectedAttribute: $selectedAttribute, selectedSoundEvent: $selectedSoundEvent)';
}


}

/// @nodoc
abstract mixin class $AppStateCopyWith<$Res>  {
  factory $AppStateCopyWith(AppState value, $Res Function(AppState) _then) = _$AppStateCopyWithImpl;
@useResult
$Res call({
 List<ItemModel> items, List<NotificationModel> notifications, List<FontModel> fonts, List<AttributeModel> attributes, List<SoundEventModel> soundEvents, bool openNavigation, ThemeSettings themeSettings,@JsonKey(includeToJson: false) ItemModel? selectedItem,@JsonKey(includeToJson: false) NotificationModel? selectedNotification,@JsonKey(includeToJson: false) FontModel? selectedFont,@JsonKey(includeToJson: false) AttributeModel? selectedAttribute,@JsonKey(includeToJson: false) SoundEventModel? selectedSoundEvent
});


$ItemModelCopyWith<$Res>? get selectedItem;$NotificationModelCopyWith<$Res>? get selectedNotification;$FontModelCopyWith<$Res>? get selectedFont;$AttributeModelCopyWith<$Res>? get selectedAttribute;$SoundEventModelCopyWith<$Res>? get selectedSoundEvent;

}
/// @nodoc
class _$AppStateCopyWithImpl<$Res>
    implements $AppStateCopyWith<$Res> {
  _$AppStateCopyWithImpl(this._self, this._then);

  final AppState _self;
  final $Res Function(AppState) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? notifications = null,Object? fonts = null,Object? attributes = null,Object? soundEvents = null,Object? openNavigation = null,Object? themeSettings = null,Object? selectedItem = freezed,Object? selectedNotification = freezed,Object? selectedFont = freezed,Object? selectedAttribute = freezed,Object? selectedSoundEvent = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ItemModel>,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<NotificationModel>,fonts: null == fonts ? _self.fonts : fonts // ignore: cast_nullable_to_non_nullable
as List<FontModel>,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as List<AttributeModel>,soundEvents: null == soundEvents ? _self.soundEvents : soundEvents // ignore: cast_nullable_to_non_nullable
as List<SoundEventModel>,openNavigation: null == openNavigation ? _self.openNavigation : openNavigation // ignore: cast_nullable_to_non_nullable
as bool,themeSettings: null == themeSettings ? _self.themeSettings : themeSettings // ignore: cast_nullable_to_non_nullable
as ThemeSettings,selectedItem: freezed == selectedItem ? _self.selectedItem : selectedItem // ignore: cast_nullable_to_non_nullable
as ItemModel?,selectedNotification: freezed == selectedNotification ? _self.selectedNotification : selectedNotification // ignore: cast_nullable_to_non_nullable
as NotificationModel?,selectedFont: freezed == selectedFont ? _self.selectedFont : selectedFont // ignore: cast_nullable_to_non_nullable
as FontModel?,selectedAttribute: freezed == selectedAttribute ? _self.selectedAttribute : selectedAttribute // ignore: cast_nullable_to_non_nullable
as AttributeModel?,selectedSoundEvent: freezed == selectedSoundEvent ? _self.selectedSoundEvent : selectedSoundEvent // ignore: cast_nullable_to_non_nullable
as SoundEventModel?,
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
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SoundEventModelCopyWith<$Res>? get selectedSoundEvent {
    if (_self.selectedSoundEvent == null) {
    return null;
  }

  return $SoundEventModelCopyWith<$Res>(_self.selectedSoundEvent!, (value) {
    return _then(_self.copyWith(selectedSoundEvent: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _AppState implements AppState {
  const _AppState({final  List<ItemModel> items = const [], final  List<NotificationModel> notifications = const [], final  List<FontModel> fonts = const [], final  List<AttributeModel> attributes = const <AttributeModel>[], final  List<SoundEventModel> soundEvents = const <SoundEventModel>[], this.openNavigation = true, this.themeSettings = const ThemeSettings(isDarkMode: false, primaryColor: Colors.blue, accentColor: Colors.blueAccent, fontScale: 1, useSystemTheme: true), @JsonKey(includeToJson: false) this.selectedItem, @JsonKey(includeToJson: false) this.selectedNotification, @JsonKey(includeToJson: false) this.selectedFont, @JsonKey(includeToJson: false) this.selectedAttribute, @JsonKey(includeToJson: false) this.selectedSoundEvent}): _items = items,_notifications = notifications,_fonts = fonts,_attributes = attributes,_soundEvents = soundEvents;
  factory _AppState.fromJson(Map<String, dynamic> json) => _$AppStateFromJson(json);

 final  List<ItemModel> _items;
@override@JsonKey() List<ItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<NotificationModel> _notifications;
@override@JsonKey() List<NotificationModel> get notifications {
  if (_notifications is EqualUnmodifiableListView) return _notifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifications);
}

 final  List<FontModel> _fonts;
@override@JsonKey() List<FontModel> get fonts {
  if (_fonts is EqualUnmodifiableListView) return _fonts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fonts);
}

 final  List<AttributeModel> _attributes;
@override@JsonKey() List<AttributeModel> get attributes {
  if (_attributes is EqualUnmodifiableListView) return _attributes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attributes);
}

 final  List<SoundEventModel> _soundEvents;
@override@JsonKey() List<SoundEventModel> get soundEvents {
  if (_soundEvents is EqualUnmodifiableListView) return _soundEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_soundEvents);
}

@override@JsonKey() final  bool openNavigation;
@override@JsonKey() final  ThemeSettings themeSettings;
@override@JsonKey(includeToJson: false) final  ItemModel? selectedItem;
@override@JsonKey(includeToJson: false) final  NotificationModel? selectedNotification;
@override@JsonKey(includeToJson: false) final  FontModel? selectedFont;
@override@JsonKey(includeToJson: false) final  AttributeModel? selectedAttribute;
@override@JsonKey(includeToJson: false) final  SoundEventModel? selectedSoundEvent;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppState&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._notifications, _notifications)&&const DeepCollectionEquality().equals(other._fonts, _fonts)&&const DeepCollectionEquality().equals(other._attributes, _attributes)&&const DeepCollectionEquality().equals(other._soundEvents, _soundEvents)&&(identical(other.openNavigation, openNavigation) || other.openNavigation == openNavigation)&&(identical(other.themeSettings, themeSettings) || other.themeSettings == themeSettings)&&(identical(other.selectedItem, selectedItem) || other.selectedItem == selectedItem)&&(identical(other.selectedNotification, selectedNotification) || other.selectedNotification == selectedNotification)&&(identical(other.selectedFont, selectedFont) || other.selectedFont == selectedFont)&&(identical(other.selectedAttribute, selectedAttribute) || other.selectedAttribute == selectedAttribute)&&(identical(other.selectedSoundEvent, selectedSoundEvent) || other.selectedSoundEvent == selectedSoundEvent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_notifications),const DeepCollectionEquality().hash(_fonts),const DeepCollectionEquality().hash(_attributes),const DeepCollectionEquality().hash(_soundEvents),openNavigation,themeSettings,selectedItem,selectedNotification,selectedFont,selectedAttribute,selectedSoundEvent);

@override
String toString() {
  return 'AppState(items: $items, notifications: $notifications, fonts: $fonts, attributes: $attributes, soundEvents: $soundEvents, openNavigation: $openNavigation, themeSettings: $themeSettings, selectedItem: $selectedItem, selectedNotification: $selectedNotification, selectedFont: $selectedFont, selectedAttribute: $selectedAttribute, selectedSoundEvent: $selectedSoundEvent)';
}


}

/// @nodoc
abstract mixin class _$AppStateCopyWith<$Res> implements $AppStateCopyWith<$Res> {
  factory _$AppStateCopyWith(_AppState value, $Res Function(_AppState) _then) = __$AppStateCopyWithImpl;
@override @useResult
$Res call({
 List<ItemModel> items, List<NotificationModel> notifications, List<FontModel> fonts, List<AttributeModel> attributes, List<SoundEventModel> soundEvents, bool openNavigation, ThemeSettings themeSettings,@JsonKey(includeToJson: false) ItemModel? selectedItem,@JsonKey(includeToJson: false) NotificationModel? selectedNotification,@JsonKey(includeToJson: false) FontModel? selectedFont,@JsonKey(includeToJson: false) AttributeModel? selectedAttribute,@JsonKey(includeToJson: false) SoundEventModel? selectedSoundEvent
});


@override $ItemModelCopyWith<$Res>? get selectedItem;@override $NotificationModelCopyWith<$Res>? get selectedNotification;@override $FontModelCopyWith<$Res>? get selectedFont;@override $AttributeModelCopyWith<$Res>? get selectedAttribute;@override $SoundEventModelCopyWith<$Res>? get selectedSoundEvent;

}
/// @nodoc
class __$AppStateCopyWithImpl<$Res>
    implements _$AppStateCopyWith<$Res> {
  __$AppStateCopyWithImpl(this._self, this._then);

  final _AppState _self;
  final $Res Function(_AppState) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? notifications = null,Object? fonts = null,Object? attributes = null,Object? soundEvents = null,Object? openNavigation = null,Object? themeSettings = null,Object? selectedItem = freezed,Object? selectedNotification = freezed,Object? selectedFont = freezed,Object? selectedAttribute = freezed,Object? selectedSoundEvent = freezed,}) {
  return _then(_AppState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ItemModel>,notifications: null == notifications ? _self._notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<NotificationModel>,fonts: null == fonts ? _self._fonts : fonts // ignore: cast_nullable_to_non_nullable
as List<FontModel>,attributes: null == attributes ? _self._attributes : attributes // ignore: cast_nullable_to_non_nullable
as List<AttributeModel>,soundEvents: null == soundEvents ? _self._soundEvents : soundEvents // ignore: cast_nullable_to_non_nullable
as List<SoundEventModel>,openNavigation: null == openNavigation ? _self.openNavigation : openNavigation // ignore: cast_nullable_to_non_nullable
as bool,themeSettings: null == themeSettings ? _self.themeSettings : themeSettings // ignore: cast_nullable_to_non_nullable
as ThemeSettings,selectedItem: freezed == selectedItem ? _self.selectedItem : selectedItem // ignore: cast_nullable_to_non_nullable
as ItemModel?,selectedNotification: freezed == selectedNotification ? _self.selectedNotification : selectedNotification // ignore: cast_nullable_to_non_nullable
as NotificationModel?,selectedFont: freezed == selectedFont ? _self.selectedFont : selectedFont // ignore: cast_nullable_to_non_nullable
as FontModel?,selectedAttribute: freezed == selectedAttribute ? _self.selectedAttribute : selectedAttribute // ignore: cast_nullable_to_non_nullable
as AttributeModel?,selectedSoundEvent: freezed == selectedSoundEvent ? _self.selectedSoundEvent : selectedSoundEvent // ignore: cast_nullable_to_non_nullable
as SoundEventModel?,
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
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SoundEventModelCopyWith<$Res>? get selectedSoundEvent {
    if (_self.selectedSoundEvent == null) {
    return null;
  }

  return $SoundEventModelCopyWith<$Res>(_self.selectedSoundEvent!, (value) {
    return _then(_self.copyWith(selectedSoundEvent: value));
  });
}
}

// dart format on
