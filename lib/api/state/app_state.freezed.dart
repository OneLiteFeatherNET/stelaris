// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppState {

@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<ItemModel> get items;@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<NotificationModel> get notifications;@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<FontModel> get fonts;@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<AttributeModel> get attributes;@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<SoundEventModel> get soundEvents;@JsonKey(includeToJson: false, includeFromJson: false) bool get isLoadingAttributesMore;@JsonKey(includeToJson: false, includeFromJson: false) bool get isLoadingMoreItems;@JsonKey(includeToJson: false, includeFromJson: false) bool get isLoadingMoreNotifications;@JsonKey(includeToJson: false, includeFromJson: false) bool get isLoadingMoreFonts;@JsonKey(includeToJson: false, includeFromJson: false) bool get isLoadingMoreSoundEvents;@JsonKey(includeToJson: false, includeFromJson: false) bool get isLoadingRelease;@JsonKey(includeToJson: false, includeFromJson: false) bool get isLoadingBranches; bool get openNavigation; ThemeSettings get themeSettings; List<Project> get projects;@JsonKey(includeToJson: false, includeFromJson: false) ItemModel? get selectedItem;@JsonKey(includeToJson: false, includeFromJson: false) NotificationModel? get selectedNotification;@JsonKey(includeToJson: false, includeFromJson: false) FontModel? get selectedFont;@JsonKey(includeToJson: false, includeFromJson: false) AttributeModel? get selectedAttribute;@JsonKey(includeToJson: false, includeFromJson: false) SoundEventModel? get selectedSoundEvent;@JsonKey(includeToJson: false, includeFromJson: false) ReleaseModel? get releaseModel;@JsonKey(includeToJson: false, includeFromJson: false) List<String>? get branches;@JsonKey(includeToJson: false, includeFromJson: false) Project? get selectedProject;@JsonKey(includeToJson: false, includeFromJson: false) ModelSearchState get modelSearch;/// The section whose selected model has form edits that haven't been
/// saved yet. Set only by the form update actions (UpdateItemAction etc.)
/// — not derived by comparing the selection to a snapshot, since lore,
/// enchantments, font chars and sound files are saved straight to the
/// API and written into the selection as well.
@JsonKey(includeToJson: false, includeFromJson: false) NavigationEntry? get unsavedChanges;@JsonKey(includeToJson: false, includeFromJson: false) AuthState get auth;
/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppStateCopyWith<AppState> get copyWith => _$AppStateCopyWithImpl<AppState>(this as AppState, _$identity);

  /// Serializes this AppState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppState&&(identical(other.items, _this.items) || other.items == _this.items)&&(identical(other.notifications, _this.notifications) || other.notifications == _this.notifications)&&(identical(other.fonts, _this.fonts) || other.fonts == _this.fonts)&&(identical(other.attributes, _this.attributes) || other.attributes == _this.attributes)&&(identical(other.soundEvents, _this.soundEvents) || other.soundEvents == _this.soundEvents)&&(identical(other.isLoadingAttributesMore, _this.isLoadingAttributesMore) || other.isLoadingAttributesMore == _this.isLoadingAttributesMore)&&(identical(other.isLoadingMoreItems, _this.isLoadingMoreItems) || other.isLoadingMoreItems == _this.isLoadingMoreItems)&&(identical(other.isLoadingMoreNotifications, _this.isLoadingMoreNotifications) || other.isLoadingMoreNotifications == _this.isLoadingMoreNotifications)&&(identical(other.isLoadingMoreFonts, _this.isLoadingMoreFonts) || other.isLoadingMoreFonts == _this.isLoadingMoreFonts)&&(identical(other.isLoadingMoreSoundEvents, _this.isLoadingMoreSoundEvents) || other.isLoadingMoreSoundEvents == _this.isLoadingMoreSoundEvents)&&(identical(other.isLoadingRelease, _this.isLoadingRelease) || other.isLoadingRelease == _this.isLoadingRelease)&&(identical(other.isLoadingBranches, _this.isLoadingBranches) || other.isLoadingBranches == _this.isLoadingBranches)&&(identical(other.openNavigation, _this.openNavigation) || other.openNavigation == _this.openNavigation)&&(identical(other.themeSettings, _this.themeSettings) || other.themeSettings == _this.themeSettings)&&const DeepCollectionEquality().equals(other.projects, _this.projects)&&(identical(other.selectedItem, _this.selectedItem) || other.selectedItem == _this.selectedItem)&&(identical(other.selectedNotification, _this.selectedNotification) || other.selectedNotification == _this.selectedNotification)&&(identical(other.selectedFont, _this.selectedFont) || other.selectedFont == _this.selectedFont)&&(identical(other.selectedAttribute, _this.selectedAttribute) || other.selectedAttribute == _this.selectedAttribute)&&(identical(other.selectedSoundEvent, _this.selectedSoundEvent) || other.selectedSoundEvent == _this.selectedSoundEvent)&&(identical(other.releaseModel, _this.releaseModel) || other.releaseModel == _this.releaseModel)&&const DeepCollectionEquality().equals(other.branches, _this.branches)&&(identical(other.selectedProject, _this.selectedProject) || other.selectedProject == _this.selectedProject)&&(identical(other.modelSearch, _this.modelSearch) || other.modelSearch == _this.modelSearch)&&(identical(other.unsavedChanges, _this.unsavedChanges) || other.unsavedChanges == _this.unsavedChanges)&&(identical(other.auth, _this.auth) || other.auth == _this.auth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppState;
  return Object.hashAll([runtimeType,_this.items,_this.notifications,_this.fonts,_this.attributes,_this.soundEvents,_this.isLoadingAttributesMore,_this.isLoadingMoreItems,_this.isLoadingMoreNotifications,_this.isLoadingMoreFonts,_this.isLoadingMoreSoundEvents,_this.isLoadingRelease,_this.isLoadingBranches,_this.openNavigation,_this.themeSettings,const DeepCollectionEquality().hash(_this.projects),_this.selectedItem,_this.selectedNotification,_this.selectedFont,_this.selectedAttribute,_this.selectedSoundEvent,_this.releaseModel,const DeepCollectionEquality().hash(_this.branches),_this.selectedProject,_this.modelSearch,_this.unsavedChanges,_this.auth]);
}

@override
String toString() {
  final _this = this as AppState;
  return 'AppState(items: ${_this.items}, notifications: ${_this.notifications}, fonts: ${_this.fonts}, attributes: ${_this.attributes}, soundEvents: ${_this.soundEvents}, isLoadingAttributesMore: ${_this.isLoadingAttributesMore}, isLoadingMoreItems: ${_this.isLoadingMoreItems}, isLoadingMoreNotifications: ${_this.isLoadingMoreNotifications}, isLoadingMoreFonts: ${_this.isLoadingMoreFonts}, isLoadingMoreSoundEvents: ${_this.isLoadingMoreSoundEvents}, isLoadingRelease: ${_this.isLoadingRelease}, isLoadingBranches: ${_this.isLoadingBranches}, openNavigation: ${_this.openNavigation}, themeSettings: ${_this.themeSettings}, projects: ${_this.projects}, selectedItem: ${_this.selectedItem}, selectedNotification: ${_this.selectedNotification}, selectedFont: ${_this.selectedFont}, selectedAttribute: ${_this.selectedAttribute}, selectedSoundEvent: ${_this.selectedSoundEvent}, releaseModel: ${_this.releaseModel}, branches: ${_this.branches}, selectedProject: ${_this.selectedProject}, modelSearch: ${_this.modelSearch}, unsavedChanges: ${_this.unsavedChanges}, auth: ${_this.auth})';
}


}

/// @nodoc
abstract mixin class $AppStateCopyWith<$Res>  {
  factory $AppStateCopyWith(AppState value, $Res Function(AppState) _then) = _$AppStateCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<ItemModel> items,@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<NotificationModel> notifications,@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<FontModel> fonts,@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<AttributeModel> attributes,@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<SoundEventModel> soundEvents,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingAttributesMore,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingMoreItems,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingMoreNotifications,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingMoreFonts,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingMoreSoundEvents,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingRelease,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingBranches, bool openNavigation, ThemeSettings themeSettings, List<Project> projects,@JsonKey(includeToJson: false, includeFromJson: false) ItemModel? selectedItem,@JsonKey(includeToJson: false, includeFromJson: false) NotificationModel? selectedNotification,@JsonKey(includeToJson: false, includeFromJson: false) FontModel? selectedFont,@JsonKey(includeToJson: false, includeFromJson: false) AttributeModel? selectedAttribute,@JsonKey(includeToJson: false, includeFromJson: false) SoundEventModel? selectedSoundEvent,@JsonKey(includeToJson: false, includeFromJson: false) ReleaseModel? releaseModel,@JsonKey(includeToJson: false, includeFromJson: false) List<String>? branches,@JsonKey(includeToJson: false, includeFromJson: false) Project? selectedProject,@JsonKey(includeToJson: false, includeFromJson: false) ModelSearchState modelSearch,@JsonKey(includeToJson: false, includeFromJson: false) NavigationEntry? unsavedChanges,@JsonKey(includeToJson: false, includeFromJson: false) AuthState auth
});


$ThemeSettingsCopyWith<$Res> get themeSettings;$ItemModelCopyWith<$Res>? get selectedItem;$NotificationModelCopyWith<$Res>? get selectedNotification;$FontModelCopyWith<$Res>? get selectedFont;$AttributeModelCopyWith<$Res>? get selectedAttribute;$SoundEventModelCopyWith<$Res>? get selectedSoundEvent;$ReleaseModelCopyWith<$Res>? get releaseModel;$ProjectCopyWith<$Res>? get selectedProject;$ModelSearchStateCopyWith<$Res> get modelSearch;

}
/// @nodoc
class _$AppStateCopyWithImpl<$Res>
    implements $AppStateCopyWith<$Res> {
  _$AppStateCopyWithImpl(this._self, this._then);

  final AppState _self;
  final $Res Function(AppState) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? notifications = null,Object? fonts = null,Object? attributes = null,Object? soundEvents = null,Object? isLoadingAttributesMore = null,Object? isLoadingMoreItems = null,Object? isLoadingMoreNotifications = null,Object? isLoadingMoreFonts = null,Object? isLoadingMoreSoundEvents = null,Object? isLoadingRelease = null,Object? isLoadingBranches = null,Object? openNavigation = null,Object? themeSettings = null,Object? projects = null,Object? selectedItem = freezed,Object? selectedNotification = freezed,Object? selectedFont = freezed,Object? selectedAttribute = freezed,Object? selectedSoundEvent = freezed,Object? releaseModel = freezed,Object? branches = freezed,Object? selectedProject = freezed,Object? modelSearch = null,Object? unsavedChanges = freezed,Object? auth = null,}) {
  return _then(AppState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as PaginatedResult<ItemModel>,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as PaginatedResult<NotificationModel>,fonts: null == fonts ? _self.fonts : fonts // ignore: cast_nullable_to_non_nullable
as PaginatedResult<FontModel>,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as PaginatedResult<AttributeModel>,soundEvents: null == soundEvents ? _self.soundEvents : soundEvents // ignore: cast_nullable_to_non_nullable
as PaginatedResult<SoundEventModel>,isLoadingAttributesMore: null == isLoadingAttributesMore ? _self.isLoadingAttributesMore : isLoadingAttributesMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreItems: null == isLoadingMoreItems ? _self.isLoadingMoreItems : isLoadingMoreItems // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreNotifications: null == isLoadingMoreNotifications ? _self.isLoadingMoreNotifications : isLoadingMoreNotifications // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreFonts: null == isLoadingMoreFonts ? _self.isLoadingMoreFonts : isLoadingMoreFonts // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreSoundEvents: null == isLoadingMoreSoundEvents ? _self.isLoadingMoreSoundEvents : isLoadingMoreSoundEvents // ignore: cast_nullable_to_non_nullable
as bool,isLoadingRelease: null == isLoadingRelease ? _self.isLoadingRelease : isLoadingRelease // ignore: cast_nullable_to_non_nullable
as bool,isLoadingBranches: null == isLoadingBranches ? _self.isLoadingBranches : isLoadingBranches // ignore: cast_nullable_to_non_nullable
as bool,openNavigation: null == openNavigation ? _self.openNavigation : openNavigation // ignore: cast_nullable_to_non_nullable
as bool,themeSettings: null == themeSettings ? _self.themeSettings : themeSettings // ignore: cast_nullable_to_non_nullable
as ThemeSettings,projects: null == projects ? _self.projects : projects // ignore: cast_nullable_to_non_nullable
as List<Project>,selectedItem: freezed == selectedItem ? _self.selectedItem : selectedItem // ignore: cast_nullable_to_non_nullable
as ItemModel?,selectedNotification: freezed == selectedNotification ? _self.selectedNotification : selectedNotification // ignore: cast_nullable_to_non_nullable
as NotificationModel?,selectedFont: freezed == selectedFont ? _self.selectedFont : selectedFont // ignore: cast_nullable_to_non_nullable
as FontModel?,selectedAttribute: freezed == selectedAttribute ? _self.selectedAttribute : selectedAttribute // ignore: cast_nullable_to_non_nullable
as AttributeModel?,selectedSoundEvent: freezed == selectedSoundEvent ? _self.selectedSoundEvent : selectedSoundEvent // ignore: cast_nullable_to_non_nullable
as SoundEventModel?,releaseModel: freezed == releaseModel ? _self.releaseModel : releaseModel // ignore: cast_nullable_to_non_nullable
as ReleaseModel?,branches: freezed == branches ? _self.branches : branches // ignore: cast_nullable_to_non_nullable
as List<String>?,selectedProject: freezed == selectedProject ? _self.selectedProject : selectedProject // ignore: cast_nullable_to_non_nullable
as Project?,modelSearch: null == modelSearch ? _self.modelSearch : modelSearch // ignore: cast_nullable_to_non_nullable
as ModelSearchState,unsavedChanges: freezed == unsavedChanges ? _self.unsavedChanges : unsavedChanges // ignore: cast_nullable_to_non_nullable
as NavigationEntry?,auth: null == auth ? _self.auth : auth // ignore: cast_nullable_to_non_nullable
as AuthState,
  ));
}
/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemeSettingsCopyWith<$Res> get themeSettings {
  
  return $ThemeSettingsCopyWith<$Res>(_self.themeSettings, (value) {
    return _then(_self.copyWith(themeSettings: value));
  });
}/// Create a copy of AppState
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
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseModelCopyWith<$Res>? get releaseModel {
    if (_self.releaseModel == null) {
    return null;
  }

  return $ReleaseModelCopyWith<$Res>(_self.releaseModel!, (value) {
    return _then(_self.copyWith(releaseModel: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCopyWith<$Res>? get selectedProject {
    if (_self.selectedProject == null) {
    return null;
  }

  return $ProjectCopyWith<$Res>(_self.selectedProject!, (value) {
    return _then(_self.copyWith(selectedProject: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModelSearchStateCopyWith<$Res> get modelSearch {
  
  return $ModelSearchStateCopyWith<$Res>(_self.modelSearch, (value) {
    return _then(_self.copyWith(modelSearch: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<ItemModel> items, @JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<NotificationModel> notifications, @JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<FontModel> fonts, @JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<AttributeModel> attributes, @JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<SoundEventModel> soundEvents, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingAttributesMore, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreItems, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreNotifications, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreFonts, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreSoundEvents, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingRelease, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingBranches,  bool openNavigation,  ThemeSettings themeSettings,  List<Project> projects, @JsonKey(includeToJson: false, includeFromJson: false)  ItemModel? selectedItem, @JsonKey(includeToJson: false, includeFromJson: false)  NotificationModel? selectedNotification, @JsonKey(includeToJson: false, includeFromJson: false)  FontModel? selectedFont, @JsonKey(includeToJson: false, includeFromJson: false)  AttributeModel? selectedAttribute, @JsonKey(includeToJson: false, includeFromJson: false)  SoundEventModel? selectedSoundEvent, @JsonKey(includeToJson: false, includeFromJson: false)  ReleaseModel? releaseModel, @JsonKey(includeToJson: false, includeFromJson: false)  List<String>? branches, @JsonKey(includeToJson: false, includeFromJson: false)  Project? selectedProject, @JsonKey(includeToJson: false, includeFromJson: false)  ModelSearchState modelSearch, @JsonKey(includeToJson: false, includeFromJson: false)  NavigationEntry? unsavedChanges, @JsonKey(includeToJson: false, includeFromJson: false)  AuthState auth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppState() when $default != null:
return $default(_that.items,_that.notifications,_that.fonts,_that.attributes,_that.soundEvents,_that.isLoadingAttributesMore,_that.isLoadingMoreItems,_that.isLoadingMoreNotifications,_that.isLoadingMoreFonts,_that.isLoadingMoreSoundEvents,_that.isLoadingRelease,_that.isLoadingBranches,_that.openNavigation,_that.themeSettings,_that.projects,_that.selectedItem,_that.selectedNotification,_that.selectedFont,_that.selectedAttribute,_that.selectedSoundEvent,_that.releaseModel,_that.branches,_that.selectedProject,_that.modelSearch,_that.unsavedChanges,_that.auth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<ItemModel> items, @JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<NotificationModel> notifications, @JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<FontModel> fonts, @JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<AttributeModel> attributes, @JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<SoundEventModel> soundEvents, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingAttributesMore, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreItems, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreNotifications, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreFonts, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreSoundEvents, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingRelease, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingBranches,  bool openNavigation,  ThemeSettings themeSettings,  List<Project> projects, @JsonKey(includeToJson: false, includeFromJson: false)  ItemModel? selectedItem, @JsonKey(includeToJson: false, includeFromJson: false)  NotificationModel? selectedNotification, @JsonKey(includeToJson: false, includeFromJson: false)  FontModel? selectedFont, @JsonKey(includeToJson: false, includeFromJson: false)  AttributeModel? selectedAttribute, @JsonKey(includeToJson: false, includeFromJson: false)  SoundEventModel? selectedSoundEvent, @JsonKey(includeToJson: false, includeFromJson: false)  ReleaseModel? releaseModel, @JsonKey(includeToJson: false, includeFromJson: false)  List<String>? branches, @JsonKey(includeToJson: false, includeFromJson: false)  Project? selectedProject, @JsonKey(includeToJson: false, includeFromJson: false)  ModelSearchState modelSearch, @JsonKey(includeToJson: false, includeFromJson: false)  NavigationEntry? unsavedChanges, @JsonKey(includeToJson: false, includeFromJson: false)  AuthState auth)  $default,) {final _that = this;
switch (_that) {
case _AppState():
return $default(_that.items,_that.notifications,_that.fonts,_that.attributes,_that.soundEvents,_that.isLoadingAttributesMore,_that.isLoadingMoreItems,_that.isLoadingMoreNotifications,_that.isLoadingMoreFonts,_that.isLoadingMoreSoundEvents,_that.isLoadingRelease,_that.isLoadingBranches,_that.openNavigation,_that.themeSettings,_that.projects,_that.selectedItem,_that.selectedNotification,_that.selectedFont,_that.selectedAttribute,_that.selectedSoundEvent,_that.releaseModel,_that.branches,_that.selectedProject,_that.modelSearch,_that.unsavedChanges,_that.auth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<ItemModel> items, @JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<NotificationModel> notifications, @JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<FontModel> fonts, @JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<AttributeModel> attributes, @JsonKey(includeToJson: false, includeFromJson: false)  PaginatedResult<SoundEventModel> soundEvents, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingAttributesMore, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreItems, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreNotifications, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreFonts, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingMoreSoundEvents, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingRelease, @JsonKey(includeToJson: false, includeFromJson: false)  bool isLoadingBranches,  bool openNavigation,  ThemeSettings themeSettings,  List<Project> projects, @JsonKey(includeToJson: false, includeFromJson: false)  ItemModel? selectedItem, @JsonKey(includeToJson: false, includeFromJson: false)  NotificationModel? selectedNotification, @JsonKey(includeToJson: false, includeFromJson: false)  FontModel? selectedFont, @JsonKey(includeToJson: false, includeFromJson: false)  AttributeModel? selectedAttribute, @JsonKey(includeToJson: false, includeFromJson: false)  SoundEventModel? selectedSoundEvent, @JsonKey(includeToJson: false, includeFromJson: false)  ReleaseModel? releaseModel, @JsonKey(includeToJson: false, includeFromJson: false)  List<String>? branches, @JsonKey(includeToJson: false, includeFromJson: false)  Project? selectedProject, @JsonKey(includeToJson: false, includeFromJson: false)  ModelSearchState modelSearch, @JsonKey(includeToJson: false, includeFromJson: false)  NavigationEntry? unsavedChanges, @JsonKey(includeToJson: false, includeFromJson: false)  AuthState auth)?  $default,) {final _that = this;
switch (_that) {
case _AppState() when $default != null:
return $default(_that.items,_that.notifications,_that.fonts,_that.attributes,_that.soundEvents,_that.isLoadingAttributesMore,_that.isLoadingMoreItems,_that.isLoadingMoreNotifications,_that.isLoadingMoreFonts,_that.isLoadingMoreSoundEvents,_that.isLoadingRelease,_that.isLoadingBranches,_that.openNavigation,_that.themeSettings,_that.projects,_that.selectedItem,_that.selectedNotification,_that.selectedFont,_that.selectedAttribute,_that.selectedSoundEvent,_that.releaseModel,_that.branches,_that.selectedProject,_that.modelSearch,_that.unsavedChanges,_that.auth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppState implements AppState {
  const _AppState({@JsonKey(includeToJson: false, includeFromJson: false) this.items = const PaginatedResult<ItemModel>(items: [], totalItems: 0, totalPages: 0, currentPage: 1, pageSize: 0), @JsonKey(includeToJson: false, includeFromJson: false) this.notifications = const PaginatedResult<NotificationModel>(items: [], totalItems: 0, totalPages: 0, currentPage: 1, pageSize: 0), @JsonKey(includeToJson: false, includeFromJson: false) this.fonts = const PaginatedResult<FontModel>(items: [], totalItems: 0, totalPages: 0, currentPage: 1, pageSize: 0), @JsonKey(includeToJson: false, includeFromJson: false) this.attributes = const PaginatedResult<AttributeModel>(items: [], totalItems: 0, totalPages: 0, currentPage: 1, pageSize: 0), @JsonKey(includeToJson: false, includeFromJson: false) this.soundEvents = const PaginatedResult<SoundEventModel>(items: [], totalItems: 0, totalPages: 0, currentPage: 1, pageSize: 0), @JsonKey(includeToJson: false, includeFromJson: false) this.isLoadingAttributesMore = false, @JsonKey(includeToJson: false, includeFromJson: false) this.isLoadingMoreItems = false, @JsonKey(includeToJson: false, includeFromJson: false) this.isLoadingMoreNotifications = false, @JsonKey(includeToJson: false, includeFromJson: false) this.isLoadingMoreFonts = false, @JsonKey(includeToJson: false, includeFromJson: false) this.isLoadingMoreSoundEvents = false, @JsonKey(includeToJson: false, includeFromJson: false) this.isLoadingRelease = false, @JsonKey(includeToJson: false, includeFromJson: false) this.isLoadingBranches = false, this.openNavigation = true, this.themeSettings = const ThemeSettings(isDarkMode: false, primaryColor: Colors.blue, accentColor: Colors.blueAccent, fontScale: 1, useSystemTheme: true), this.projects = const [], @JsonKey(includeToJson: false, includeFromJson: false) this.selectedItem, @JsonKey(includeToJson: false, includeFromJson: false) this.selectedNotification, @JsonKey(includeToJson: false, includeFromJson: false) this.selectedFont, @JsonKey(includeToJson: false, includeFromJson: false) this.selectedAttribute, @JsonKey(includeToJson: false, includeFromJson: false) this.selectedSoundEvent, @JsonKey(includeToJson: false, includeFromJson: false) this.releaseModel, @JsonKey(includeToJson: false, includeFromJson: false) this.branches, @JsonKey(includeToJson: false, includeFromJson: false) this.selectedProject, @JsonKey(includeToJson: false, includeFromJson: false) this.modelSearch = const ModelSearchState(), @JsonKey(includeToJson: false, includeFromJson: false) this.unsavedChanges, @JsonKey(includeToJson: false, includeFromJson: false) this.auth = const AuthState.disabled()});
  factory _AppState.fromJson(Map<String, dynamic> json) => _$AppStateFromJson(json);

@override@JsonKey(includeToJson: false, includeFromJson: false) final  PaginatedResult<ItemModel> items;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  PaginatedResult<NotificationModel> notifications;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  PaginatedResult<FontModel> fonts;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  PaginatedResult<AttributeModel> attributes;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  PaginatedResult<SoundEventModel> soundEvents;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  bool isLoadingAttributesMore;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  bool isLoadingMoreItems;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  bool isLoadingMoreNotifications;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  bool isLoadingMoreFonts;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  bool isLoadingMoreSoundEvents;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  bool isLoadingRelease;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  bool isLoadingBranches;
@override@JsonKey() final  bool openNavigation;
@override@JsonKey() final  ThemeSettings themeSettings;
@override@JsonKey() final  List<Project> projects;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  ItemModel? selectedItem;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  NotificationModel? selectedNotification;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  FontModel? selectedFont;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  AttributeModel? selectedAttribute;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  SoundEventModel? selectedSoundEvent;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  ReleaseModel? releaseModel;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  List<String>? branches;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  Project? selectedProject;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  ModelSearchState modelSearch;
/// The section whose selected model has form edits that haven't been
/// saved yet. Set only by the form update actions (UpdateItemAction etc.)
/// — not derived by comparing the selection to a snapshot, since lore,
/// enchantments, font chars and sound files are saved straight to the
/// API and written into the selection as well.
@override@JsonKey(includeToJson: false, includeFromJson: false) final  NavigationEntry? unsavedChanges;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  AuthState auth;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppState&&(identical(other.items, items) || other.items == items)&&(identical(other.notifications, notifications) || other.notifications == notifications)&&(identical(other.fonts, fonts) || other.fonts == fonts)&&(identical(other.attributes, attributes) || other.attributes == attributes)&&(identical(other.soundEvents, soundEvents) || other.soundEvents == soundEvents)&&(identical(other.isLoadingAttributesMore, isLoadingAttributesMore) || other.isLoadingAttributesMore == isLoadingAttributesMore)&&(identical(other.isLoadingMoreItems, isLoadingMoreItems) || other.isLoadingMoreItems == isLoadingMoreItems)&&(identical(other.isLoadingMoreNotifications, isLoadingMoreNotifications) || other.isLoadingMoreNotifications == isLoadingMoreNotifications)&&(identical(other.isLoadingMoreFonts, isLoadingMoreFonts) || other.isLoadingMoreFonts == isLoadingMoreFonts)&&(identical(other.isLoadingMoreSoundEvents, isLoadingMoreSoundEvents) || other.isLoadingMoreSoundEvents == isLoadingMoreSoundEvents)&&(identical(other.isLoadingRelease, isLoadingRelease) || other.isLoadingRelease == isLoadingRelease)&&(identical(other.isLoadingBranches, isLoadingBranches) || other.isLoadingBranches == isLoadingBranches)&&(identical(other.openNavigation, openNavigation) || other.openNavigation == openNavigation)&&(identical(other.themeSettings, themeSettings) || other.themeSettings == themeSettings)&&const DeepCollectionEquality().equals(other.projects, projects)&&(identical(other.selectedItem, selectedItem) || other.selectedItem == selectedItem)&&(identical(other.selectedNotification, selectedNotification) || other.selectedNotification == selectedNotification)&&(identical(other.selectedFont, selectedFont) || other.selectedFont == selectedFont)&&(identical(other.selectedAttribute, selectedAttribute) || other.selectedAttribute == selectedAttribute)&&(identical(other.selectedSoundEvent, selectedSoundEvent) || other.selectedSoundEvent == selectedSoundEvent)&&(identical(other.releaseModel, releaseModel) || other.releaseModel == releaseModel)&&const DeepCollectionEquality().equals(other.branches, branches)&&(identical(other.selectedProject, selectedProject) || other.selectedProject == selectedProject)&&(identical(other.modelSearch, modelSearch) || other.modelSearch == modelSearch)&&(identical(other.unsavedChanges, unsavedChanges) || other.unsavedChanges == unsavedChanges)&&(identical(other.auth, auth) || other.auth == auth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,items,notifications,fonts,attributes,soundEvents,isLoadingAttributesMore,isLoadingMoreItems,isLoadingMoreNotifications,isLoadingMoreFonts,isLoadingMoreSoundEvents,isLoadingRelease,isLoadingBranches,openNavigation,themeSettings,const DeepCollectionEquality().hash(projects),selectedItem,selectedNotification,selectedFont,selectedAttribute,selectedSoundEvent,releaseModel,const DeepCollectionEquality().hash(branches),selectedProject,modelSearch,unsavedChanges,auth]);
}

@override
String toString() {
    return 'AppState(items: $items, notifications: $notifications, fonts: $fonts, attributes: $attributes, soundEvents: $soundEvents, isLoadingAttributesMore: $isLoadingAttributesMore, isLoadingMoreItems: $isLoadingMoreItems, isLoadingMoreNotifications: $isLoadingMoreNotifications, isLoadingMoreFonts: $isLoadingMoreFonts, isLoadingMoreSoundEvents: $isLoadingMoreSoundEvents, isLoadingRelease: $isLoadingRelease, isLoadingBranches: $isLoadingBranches, openNavigation: $openNavigation, themeSettings: $themeSettings, projects: $projects, selectedItem: $selectedItem, selectedNotification: $selectedNotification, selectedFont: $selectedFont, selectedAttribute: $selectedAttribute, selectedSoundEvent: $selectedSoundEvent, releaseModel: $releaseModel, branches: $branches, selectedProject: $selectedProject, modelSearch: $modelSearch, unsavedChanges: $unsavedChanges, auth: $auth)';
}


}

/// @nodoc
abstract mixin class _$AppStateCopyWith<$Res> implements $AppStateCopyWith<$Res> {
  factory _$AppStateCopyWith(_AppState value, $Res Function(_AppState) _then) = __$AppStateCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<ItemModel> items,@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<NotificationModel> notifications,@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<FontModel> fonts,@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<AttributeModel> attributes,@JsonKey(includeToJson: false, includeFromJson: false) PaginatedResult<SoundEventModel> soundEvents,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingAttributesMore,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingMoreItems,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingMoreNotifications,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingMoreFonts,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingMoreSoundEvents,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingRelease,@JsonKey(includeToJson: false, includeFromJson: false) bool isLoadingBranches, bool openNavigation, ThemeSettings themeSettings, List<Project> projects,@JsonKey(includeToJson: false, includeFromJson: false) ItemModel? selectedItem,@JsonKey(includeToJson: false, includeFromJson: false) NotificationModel? selectedNotification,@JsonKey(includeToJson: false, includeFromJson: false) FontModel? selectedFont,@JsonKey(includeToJson: false, includeFromJson: false) AttributeModel? selectedAttribute,@JsonKey(includeToJson: false, includeFromJson: false) SoundEventModel? selectedSoundEvent,@JsonKey(includeToJson: false, includeFromJson: false) ReleaseModel? releaseModel,@JsonKey(includeToJson: false, includeFromJson: false) List<String>? branches,@JsonKey(includeToJson: false, includeFromJson: false) Project? selectedProject,@JsonKey(includeToJson: false, includeFromJson: false) ModelSearchState modelSearch,@JsonKey(includeToJson: false, includeFromJson: false) NavigationEntry? unsavedChanges,@JsonKey(includeToJson: false, includeFromJson: false) AuthState auth
});


@override $ThemeSettingsCopyWith<$Res> get themeSettings;@override $ItemModelCopyWith<$Res>? get selectedItem;@override $NotificationModelCopyWith<$Res>? get selectedNotification;@override $FontModelCopyWith<$Res>? get selectedFont;@override $AttributeModelCopyWith<$Res>? get selectedAttribute;@override $SoundEventModelCopyWith<$Res>? get selectedSoundEvent;@override $ReleaseModelCopyWith<$Res>? get releaseModel;@override $ProjectCopyWith<$Res>? get selectedProject;@override $ModelSearchStateCopyWith<$Res> get modelSearch;

}
/// @nodoc
class __$AppStateCopyWithImpl<$Res>
    implements _$AppStateCopyWith<$Res> {
  __$AppStateCopyWithImpl(this._self, this._then);

  final _AppState _self;
  final $Res Function(_AppState) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? notifications = null,Object? fonts = null,Object? attributes = null,Object? soundEvents = null,Object? isLoadingAttributesMore = null,Object? isLoadingMoreItems = null,Object? isLoadingMoreNotifications = null,Object? isLoadingMoreFonts = null,Object? isLoadingMoreSoundEvents = null,Object? isLoadingRelease = null,Object? isLoadingBranches = null,Object? openNavigation = null,Object? themeSettings = null,Object? projects = null,Object? selectedItem = freezed,Object? selectedNotification = freezed,Object? selectedFont = freezed,Object? selectedAttribute = freezed,Object? selectedSoundEvent = freezed,Object? releaseModel = freezed,Object? branches = freezed,Object? selectedProject = freezed,Object? modelSearch = null,Object? unsavedChanges = freezed,Object? auth = null,}) {
  return _then(_AppState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as PaginatedResult<ItemModel>,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as PaginatedResult<NotificationModel>,fonts: null == fonts ? _self.fonts : fonts // ignore: cast_nullable_to_non_nullable
as PaginatedResult<FontModel>,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as PaginatedResult<AttributeModel>,soundEvents: null == soundEvents ? _self.soundEvents : soundEvents // ignore: cast_nullable_to_non_nullable
as PaginatedResult<SoundEventModel>,isLoadingAttributesMore: null == isLoadingAttributesMore ? _self.isLoadingAttributesMore : isLoadingAttributesMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreItems: null == isLoadingMoreItems ? _self.isLoadingMoreItems : isLoadingMoreItems // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreNotifications: null == isLoadingMoreNotifications ? _self.isLoadingMoreNotifications : isLoadingMoreNotifications // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreFonts: null == isLoadingMoreFonts ? _self.isLoadingMoreFonts : isLoadingMoreFonts // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreSoundEvents: null == isLoadingMoreSoundEvents ? _self.isLoadingMoreSoundEvents : isLoadingMoreSoundEvents // ignore: cast_nullable_to_non_nullable
as bool,isLoadingRelease: null == isLoadingRelease ? _self.isLoadingRelease : isLoadingRelease // ignore: cast_nullable_to_non_nullable
as bool,isLoadingBranches: null == isLoadingBranches ? _self.isLoadingBranches : isLoadingBranches // ignore: cast_nullable_to_non_nullable
as bool,openNavigation: null == openNavigation ? _self.openNavigation : openNavigation // ignore: cast_nullable_to_non_nullable
as bool,themeSettings: null == themeSettings ? _self.themeSettings : themeSettings // ignore: cast_nullable_to_non_nullable
as ThemeSettings,projects: null == projects ? _self.projects : projects // ignore: cast_nullable_to_non_nullable
as List<Project>,selectedItem: freezed == selectedItem ? _self.selectedItem : selectedItem // ignore: cast_nullable_to_non_nullable
as ItemModel?,selectedNotification: freezed == selectedNotification ? _self.selectedNotification : selectedNotification // ignore: cast_nullable_to_non_nullable
as NotificationModel?,selectedFont: freezed == selectedFont ? _self.selectedFont : selectedFont // ignore: cast_nullable_to_non_nullable
as FontModel?,selectedAttribute: freezed == selectedAttribute ? _self.selectedAttribute : selectedAttribute // ignore: cast_nullable_to_non_nullable
as AttributeModel?,selectedSoundEvent: freezed == selectedSoundEvent ? _self.selectedSoundEvent : selectedSoundEvent // ignore: cast_nullable_to_non_nullable
as SoundEventModel?,releaseModel: freezed == releaseModel ? _self.releaseModel : releaseModel // ignore: cast_nullable_to_non_nullable
as ReleaseModel?,branches: freezed == branches ? _self.branches : branches // ignore: cast_nullable_to_non_nullable
as List<String>?,selectedProject: freezed == selectedProject ? _self.selectedProject : selectedProject // ignore: cast_nullable_to_non_nullable
as Project?,modelSearch: null == modelSearch ? _self.modelSearch : modelSearch // ignore: cast_nullable_to_non_nullable
as ModelSearchState,unsavedChanges: freezed == unsavedChanges ? _self.unsavedChanges : unsavedChanges // ignore: cast_nullable_to_non_nullable
as NavigationEntry?,auth: null == auth ? _self.auth : auth // ignore: cast_nullable_to_non_nullable
as AuthState,
  ));
}

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemeSettingsCopyWith<$Res> get themeSettings {
  
  return $ThemeSettingsCopyWith<$Res>(_self.themeSettings, (value) {
    return _then(_self.copyWith(themeSettings: value));
  });
}/// Create a copy of AppState
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
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseModelCopyWith<$Res>? get releaseModel {
    if (_self.releaseModel == null) {
    return null;
  }

  return $ReleaseModelCopyWith<$Res>(_self.releaseModel!, (value) {
    return _then(_self.copyWith(releaseModel: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCopyWith<$Res>? get selectedProject {
    if (_self.selectedProject == null) {
    return null;
  }

  return $ProjectCopyWith<$Res>(_self.selectedProject!, (value) {
    return _then(_self.copyWith(selectedProject: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModelSearchStateCopyWith<$Res> get modelSearch {
  
  return $ModelSearchStateCopyWith<$Res>(_self.modelSearch, (value) {
    return _then(_self.copyWith(modelSearch: value));
  });
}
}

// dart format on
