// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'font_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FontModel {
  String? get id;
  String? get modelName;
  String? get name;
  String? get description;
  FontType get type;
  List<String>? get chars;
  int? get ascent;
  int? get height;
  List<double>? get shift;

  /// Create a copy of FontModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FontModelCopyWith<FontModel> get copyWith =>
      _$FontModelCopyWithImpl<FontModel>(this as FontModel, _$identity);

  /// Serializes this FontModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FontModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.modelName, modelName) ||
                other.modelName == modelName) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other.chars, chars) &&
            (identical(other.ascent, ascent) || other.ascent == ascent) &&
            (identical(other.height, height) || other.height == height) &&
            const DeepCollectionEquality().equals(other.shift, shift));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      modelName,
      name,
      description,
      type,
      const DeepCollectionEquality().hash(chars),
      ascent,
      height,
      const DeepCollectionEquality().hash(shift));

  @override
  String toString() {
    return 'FontModel(id: $id, modelName: $modelName, name: $name, description: $description, type: $type, chars: $chars, ascent: $ascent, height: $height, shift: $shift)';
  }
}

/// @nodoc
abstract mixin class $FontModelCopyWith<$Res> {
  factory $FontModelCopyWith(FontModel value, $Res Function(FontModel) _then) =
      _$FontModelCopyWithImpl;
  @useResult
  $Res call(
      {String? id,
      String? modelName,
      String? name,
      String? description,
      FontType type,
      List<String>? chars,
      int? ascent,
      int? height,
      List<double>? shift});
}

/// @nodoc
class _$FontModelCopyWithImpl<$Res> implements $FontModelCopyWith<$Res> {
  _$FontModelCopyWithImpl(this._self, this._then);

  final FontModel _self;
  final $Res Function(FontModel) _then;

  /// Create a copy of FontModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? modelName = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? type = null,
    Object? chars = freezed,
    Object? ascent = freezed,
    Object? height = freezed,
    Object? shift = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      modelName: freezed == modelName
          ? _self.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as FontType,
      chars: freezed == chars
          ? _self.chars
          : chars // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      ascent: freezed == ascent
          ? _self.ascent
          : ascent // ignore: cast_nullable_to_non_nullable
              as int?,
      height: freezed == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      shift: freezed == shift
          ? _self.shift
          : shift // ignore: cast_nullable_to_non_nullable
              as List<double>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _FontModel extends FontModel {
  const _FontModel(
      {this.id,
      this.modelName,
      this.name,
      this.description,
      this.type = FontType.bitmap,
      final List<String>? chars = const [],
      this.ascent = 0,
      this.height = 0,
      final List<double>? shift = const []})
      : _chars = chars,
        _shift = shift,
        super._();
  factory _FontModel.fromJson(Map<String, dynamic> json) =>
      _$FontModelFromJson(json);

  @override
  final String? id;
  @override
  final String? modelName;
  @override
  final String? name;
  @override
  final String? description;
  @override
  @JsonKey()
  final FontType type;
  final List<String>? _chars;
  @override
  @JsonKey()
  List<String>? get chars {
    final value = _chars;
    if (value == null) return null;
    if (_chars is EqualUnmodifiableListView) return _chars;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final int? ascent;
  @override
  @JsonKey()
  final int? height;
  final List<double>? _shift;
  @override
  @JsonKey()
  List<double>? get shift {
    final value = _shift;
    if (value == null) return null;
    if (_shift is EqualUnmodifiableListView) return _shift;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of FontModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FontModelCopyWith<_FontModel> get copyWith =>
      __$FontModelCopyWithImpl<_FontModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$FontModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FontModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.modelName, modelName) ||
                other.modelName == modelName) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._chars, _chars) &&
            (identical(other.ascent, ascent) || other.ascent == ascent) &&
            (identical(other.height, height) || other.height == height) &&
            const DeepCollectionEquality().equals(other._shift, _shift));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      modelName,
      name,
      description,
      type,
      const DeepCollectionEquality().hash(_chars),
      ascent,
      height,
      const DeepCollectionEquality().hash(_shift));

  @override
  String toString() {
    return 'FontModel(id: $id, modelName: $modelName, name: $name, description: $description, type: $type, chars: $chars, ascent: $ascent, height: $height, shift: $shift)';
  }
}

/// @nodoc
abstract mixin class _$FontModelCopyWith<$Res>
    implements $FontModelCopyWith<$Res> {
  factory _$FontModelCopyWith(
          _FontModel value, $Res Function(_FontModel) _then) =
      __$FontModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? id,
      String? modelName,
      String? name,
      String? description,
      FontType type,
      List<String>? chars,
      int? ascent,
      int? height,
      List<double>? shift});
}

/// @nodoc
class __$FontModelCopyWithImpl<$Res> implements _$FontModelCopyWith<$Res> {
  __$FontModelCopyWithImpl(this._self, this._then);

  final _FontModel _self;
  final $Res Function(_FontModel) _then;

  /// Create a copy of FontModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? modelName = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? type = null,
    Object? chars = freezed,
    Object? ascent = freezed,
    Object? height = freezed,
    Object? shift = freezed,
  }) {
    return _then(_FontModel(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      modelName: freezed == modelName
          ? _self.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as FontType,
      chars: freezed == chars
          ? _self._chars
          : chars // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      ascent: freezed == ascent
          ? _self.ascent
          : ascent // ignore: cast_nullable_to_non_nullable
              as int?,
      height: freezed == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      shift: freezed == shift
          ? _self._shift
          : shift // ignore: cast_nullable_to_non_nullable
              as List<double>?,
    ));
  }
}

// dart format on
