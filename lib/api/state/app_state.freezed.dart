// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppState _$AppStateFromJson(Map<String, dynamic> json) {
  return _AppState.fromJson(json);
}

/// @nodoc
mixin _$AppState {
  List<ItemModel> get items => throw _privateConstructorUsedError;
  List<NotificationModel> get notifications =>
      throw _privateConstructorUsedError;
  List<FontModel> get fonts => throw _privateConstructorUsedError;
  List<AttributeModel> get attributes => throw _privateConstructorUsedError;
  bool get openNavigation => throw _privateConstructorUsedError;
  bool get nightMode => throw _privateConstructorUsedError;
  @JsonKey(includeToJson: false)
  ItemModel? get selectedItem => throw _privateConstructorUsedError;
  @JsonKey(includeToJson: false)
  NotificationModel? get selectedNotification =>
      throw _privateConstructorUsedError;
  @JsonKey(includeToJson: false)
  FontModel? get selectedFont => throw _privateConstructorUsedError;
  @JsonKey(includeToJson: false)
  AttributeModel? get selectedAttribute => throw _privateConstructorUsedError;

  /// Serializes this AppState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppStateCopyWith<AppState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppStateCopyWith<$Res> {
  factory $AppStateCopyWith(AppState value, $Res Function(AppState) then) =
      _$AppStateCopyWithImpl<$Res, AppState>;
  @useResult
  $Res call({
    List<ItemModel> items,
    List<NotificationModel> notifications,
    List<FontModel> fonts,
    List<AttributeModel> attributes,
    bool openNavigation,
    bool nightMode,
    @JsonKey(includeToJson: false) ItemModel? selectedItem,
    @JsonKey(includeToJson: false) NotificationModel? selectedNotification,
    @JsonKey(includeToJson: false) FontModel? selectedFont,
    @JsonKey(includeToJson: false) AttributeModel? selectedAttribute,
  });

  $ItemModelCopyWith<$Res>? get selectedItem;
  $NotificationModelCopyWith<$Res>? get selectedNotification;
  $FontModelCopyWith<$Res>? get selectedFont;
  $AttributeModelCopyWith<$Res>? get selectedAttribute;
}

/// @nodoc
class _$AppStateCopyWithImpl<$Res, $Val extends AppState>
    implements $AppStateCopyWith<$Res> {
  _$AppStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? notifications = null,
    Object? fonts = null,
    Object? attributes = null,
    Object? openNavigation = null,
    Object? nightMode = null,
    Object? selectedItem = freezed,
    Object? selectedNotification = freezed,
    Object? selectedFont = freezed,
    Object? selectedAttribute = freezed,
  }) {
    return _then(
      _value.copyWith(
            items:
                null == items
                    ? _value.items
                    : items // ignore: cast_nullable_to_non_nullable
                        as List<ItemModel>,
            notifications:
                null == notifications
                    ? _value.notifications
                    : notifications // ignore: cast_nullable_to_non_nullable
                        as List<NotificationModel>,
            fonts:
                null == fonts
                    ? _value.fonts
                    : fonts // ignore: cast_nullable_to_non_nullable
                        as List<FontModel>,
            attributes:
                null == attributes
                    ? _value.attributes
                    : attributes // ignore: cast_nullable_to_non_nullable
                        as List<AttributeModel>,
            openNavigation:
                null == openNavigation
                    ? _value.openNavigation
                    : openNavigation // ignore: cast_nullable_to_non_nullable
                        as bool,
            nightMode:
                null == nightMode
                    ? _value.nightMode
                    : nightMode // ignore: cast_nullable_to_non_nullable
                        as bool,
            selectedItem:
                freezed == selectedItem
                    ? _value.selectedItem
                    : selectedItem // ignore: cast_nullable_to_non_nullable
                        as ItemModel?,
            selectedNotification:
                freezed == selectedNotification
                    ? _value.selectedNotification
                    : selectedNotification // ignore: cast_nullable_to_non_nullable
                        as NotificationModel?,
            selectedFont:
                freezed == selectedFont
                    ? _value.selectedFont
                    : selectedFont // ignore: cast_nullable_to_non_nullable
                        as FontModel?,
            selectedAttribute:
                freezed == selectedAttribute
                    ? _value.selectedAttribute
                    : selectedAttribute // ignore: cast_nullable_to_non_nullable
                        as AttributeModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ItemModelCopyWith<$Res>? get selectedItem {
    if (_value.selectedItem == null) {
      return null;
    }

    return $ItemModelCopyWith<$Res>(_value.selectedItem!, (value) {
      return _then(_value.copyWith(selectedItem: value) as $Val);
    });
  }

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NotificationModelCopyWith<$Res>? get selectedNotification {
    if (_value.selectedNotification == null) {
      return null;
    }

    return $NotificationModelCopyWith<$Res>(_value.selectedNotification!, (
      value,
    ) {
      return _then(_value.copyWith(selectedNotification: value) as $Val);
    });
  }

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FontModelCopyWith<$Res>? get selectedFont {
    if (_value.selectedFont == null) {
      return null;
    }

    return $FontModelCopyWith<$Res>(_value.selectedFont!, (value) {
      return _then(_value.copyWith(selectedFont: value) as $Val);
    });
  }

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttributeModelCopyWith<$Res>? get selectedAttribute {
    if (_value.selectedAttribute == null) {
      return null;
    }

    return $AttributeModelCopyWith<$Res>(_value.selectedAttribute!, (value) {
      return _then(_value.copyWith(selectedAttribute: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppStateImplCopyWith<$Res>
    implements $AppStateCopyWith<$Res> {
  factory _$$AppStateImplCopyWith(
    _$AppStateImpl value,
    $Res Function(_$AppStateImpl) then,
  ) = __$$AppStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ItemModel> items,
    List<NotificationModel> notifications,
    List<FontModel> fonts,
    List<AttributeModel> attributes,
    bool openNavigation,
    bool nightMode,
    @JsonKey(includeToJson: false) ItemModel? selectedItem,
    @JsonKey(includeToJson: false) NotificationModel? selectedNotification,
    @JsonKey(includeToJson: false) FontModel? selectedFont,
    @JsonKey(includeToJson: false) AttributeModel? selectedAttribute,
  });

  @override
  $ItemModelCopyWith<$Res>? get selectedItem;
  @override
  $NotificationModelCopyWith<$Res>? get selectedNotification;
  @override
  $FontModelCopyWith<$Res>? get selectedFont;
  @override
  $AttributeModelCopyWith<$Res>? get selectedAttribute;
}

/// @nodoc
class __$$AppStateImplCopyWithImpl<$Res>
    extends _$AppStateCopyWithImpl<$Res, _$AppStateImpl>
    implements _$$AppStateImplCopyWith<$Res> {
  __$$AppStateImplCopyWithImpl(
    _$AppStateImpl _value,
    $Res Function(_$AppStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? notifications = null,
    Object? fonts = null,
    Object? attributes = null,
    Object? openNavigation = null,
    Object? nightMode = null,
    Object? selectedItem = freezed,
    Object? selectedNotification = freezed,
    Object? selectedFont = freezed,
    Object? selectedAttribute = freezed,
  }) {
    return _then(
      _$AppStateImpl(
        items:
            null == items
                ? _value._items
                : items // ignore: cast_nullable_to_non_nullable
                    as List<ItemModel>,
        notifications:
            null == notifications
                ? _value._notifications
                : notifications // ignore: cast_nullable_to_non_nullable
                    as List<NotificationModel>,
        fonts:
            null == fonts
                ? _value._fonts
                : fonts // ignore: cast_nullable_to_non_nullable
                    as List<FontModel>,
        attributes:
            null == attributes
                ? _value._attributes
                : attributes // ignore: cast_nullable_to_non_nullable
                    as List<AttributeModel>,
        openNavigation:
            null == openNavigation
                ? _value.openNavigation
                : openNavigation // ignore: cast_nullable_to_non_nullable
                    as bool,
        nightMode:
            null == nightMode
                ? _value.nightMode
                : nightMode // ignore: cast_nullable_to_non_nullable
                    as bool,
        selectedItem:
            freezed == selectedItem
                ? _value.selectedItem
                : selectedItem // ignore: cast_nullable_to_non_nullable
                    as ItemModel?,
        selectedNotification:
            freezed == selectedNotification
                ? _value.selectedNotification
                : selectedNotification // ignore: cast_nullable_to_non_nullable
                    as NotificationModel?,
        selectedFont:
            freezed == selectedFont
                ? _value.selectedFont
                : selectedFont // ignore: cast_nullable_to_non_nullable
                    as FontModel?,
        selectedAttribute:
            freezed == selectedAttribute
                ? _value.selectedAttribute
                : selectedAttribute // ignore: cast_nullable_to_non_nullable
                    as AttributeModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppStateImpl implements _AppState {
  const _$AppStateImpl({
    final List<ItemModel> items = const [],
    final List<NotificationModel> notifications = const [],
    final List<FontModel> fonts = const [],
    final List<AttributeModel> attributes = const <AttributeModel>[],
    this.openNavigation = true,
    this.nightMode = true,
    @JsonKey(includeToJson: false) this.selectedItem,
    @JsonKey(includeToJson: false) this.selectedNotification,
    @JsonKey(includeToJson: false) this.selectedFont,
    @JsonKey(includeToJson: false) this.selectedAttribute,
  }) : _items = items,
       _notifications = notifications,
       _fonts = fonts,
       _attributes = attributes;

  factory _$AppStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppStateImplFromJson(json);

  final List<ItemModel> _items;
  @override
  @JsonKey()
  List<ItemModel> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final List<NotificationModel> _notifications;
  @override
  @JsonKey()
  List<NotificationModel> get notifications {
    if (_notifications is EqualUnmodifiableListView) return _notifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifications);
  }

  final List<FontModel> _fonts;
  @override
  @JsonKey()
  List<FontModel> get fonts {
    if (_fonts is EqualUnmodifiableListView) return _fonts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fonts);
  }

  final List<AttributeModel> _attributes;
  @override
  @JsonKey()
  List<AttributeModel> get attributes {
    if (_attributes is EqualUnmodifiableListView) return _attributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attributes);
  }

  @override
  @JsonKey()
  final bool openNavigation;
  @override
  @JsonKey()
  final bool nightMode;
  @override
  @JsonKey(includeToJson: false)
  final ItemModel? selectedItem;
  @override
  @JsonKey(includeToJson: false)
  final NotificationModel? selectedNotification;
  @override
  @JsonKey(includeToJson: false)
  final FontModel? selectedFont;
  @override
  @JsonKey(includeToJson: false)
  final AttributeModel? selectedAttribute;

  @override
  String toString() {
    return 'AppState(items: $items, notifications: $notifications, fonts: $fonts, attributes: $attributes, openNavigation: $openNavigation, nightMode: $nightMode, selectedItem: $selectedItem, selectedNotification: $selectedNotification, selectedFont: $selectedFont, selectedAttribute: $selectedAttribute)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(
              other._notifications,
              _notifications,
            ) &&
            const DeepCollectionEquality().equals(other._fonts, _fonts) &&
            const DeepCollectionEquality().equals(
              other._attributes,
              _attributes,
            ) &&
            (identical(other.openNavigation, openNavigation) ||
                other.openNavigation == openNavigation) &&
            (identical(other.nightMode, nightMode) ||
                other.nightMode == nightMode) &&
            (identical(other.selectedItem, selectedItem) ||
                other.selectedItem == selectedItem) &&
            (identical(other.selectedNotification, selectedNotification) ||
                other.selectedNotification == selectedNotification) &&
            (identical(other.selectedFont, selectedFont) ||
                other.selectedFont == selectedFont) &&
            (identical(other.selectedAttribute, selectedAttribute) ||
                other.selectedAttribute == selectedAttribute));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    const DeepCollectionEquality().hash(_notifications),
    const DeepCollectionEquality().hash(_fonts),
    const DeepCollectionEquality().hash(_attributes),
    openNavigation,
    nightMode,
    selectedItem,
    selectedNotification,
    selectedFont,
    selectedAttribute,
  );

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppStateImplCopyWith<_$AppStateImpl> get copyWith =>
      __$$AppStateImplCopyWithImpl<_$AppStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppStateImplToJson(this);
  }
}

abstract class _AppState implements AppState {
  const factory _AppState({
    final List<ItemModel> items,
    final List<NotificationModel> notifications,
    final List<FontModel> fonts,
    final List<AttributeModel> attributes,
    final bool openNavigation,
    final bool nightMode,
    @JsonKey(includeToJson: false) final ItemModel? selectedItem,
    @JsonKey(includeToJson: false)
    final NotificationModel? selectedNotification,
    @JsonKey(includeToJson: false) final FontModel? selectedFont,
    @JsonKey(includeToJson: false) final AttributeModel? selectedAttribute,
  }) = _$AppStateImpl;

  factory _AppState.fromJson(Map<String, dynamic> json) =
      _$AppStateImpl.fromJson;

  @override
  List<ItemModel> get items;
  @override
  List<NotificationModel> get notifications;
  @override
  List<FontModel> get fonts;
  @override
  List<AttributeModel> get attributes;
  @override
  bool get openNavigation;
  @override
  bool get nightMode;
  @override
  @JsonKey(includeToJson: false)
  ItemModel? get selectedItem;
  @override
  @JsonKey(includeToJson: false)
  NotificationModel? get selectedNotification;
  @override
  @JsonKey(includeToJson: false)
  FontModel? get selectedFont;
  @override
  @JsonKey(includeToJson: false)
  AttributeModel? get selectedAttribute;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppStateImplCopyWith<_$AppStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
