// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attribute_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AttributeModel _$AttributeModelFromJson(Map<String, dynamic> json) {
  return _AttributeModel.fromJson(json);
}

/// @nodoc
mixin _$AttributeModel {
  String? get id => throw _privateConstructorUsedError;
  String? get modelName => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  @freezed
  double? get defaultValue => throw _privateConstructorUsedError;
  double? get maximumValue => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AttributeModelCopyWith<AttributeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttributeModelCopyWith<$Res> {
  factory $AttributeModelCopyWith(
          AttributeModel value, $Res Function(AttributeModel) then) =
      _$AttributeModelCopyWithImpl<$Res, AttributeModel>;
  @useResult
  $Res call(
      {String? id,
      String? modelName,
      String? name,
      @freezed double? defaultValue,
      double? maximumValue});
}

/// @nodoc
class _$AttributeModelCopyWithImpl<$Res, $Val extends AttributeModel>
    implements $AttributeModelCopyWith<$Res> {
  _$AttributeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? modelName = freezed,
    Object? name = freezed,
    Object? defaultValue = freezed,
    Object? maximumValue = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      modelName: freezed == modelName
          ? _value.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultValue: freezed == defaultValue
          ? _value.defaultValue
          : defaultValue // ignore: cast_nullable_to_non_nullable
              as double?,
      maximumValue: freezed == maximumValue
          ? _value.maximumValue
          : maximumValue // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AttributeModelImplCopyWith<$Res>
    implements $AttributeModelCopyWith<$Res> {
  factory _$$AttributeModelImplCopyWith(_$AttributeModelImpl value,
          $Res Function(_$AttributeModelImpl) then) =
      __$$AttributeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? modelName,
      String? name,
      @freezed double? defaultValue,
      double? maximumValue});
}

/// @nodoc
class __$$AttributeModelImplCopyWithImpl<$Res>
    extends _$AttributeModelCopyWithImpl<$Res, _$AttributeModelImpl>
    implements _$$AttributeModelImplCopyWith<$Res> {
  __$$AttributeModelImplCopyWithImpl(
      _$AttributeModelImpl _value, $Res Function(_$AttributeModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? modelName = freezed,
    Object? name = freezed,
    Object? defaultValue = freezed,
    Object? maximumValue = freezed,
  }) {
    return _then(_$AttributeModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      modelName: freezed == modelName
          ? _value.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultValue: freezed == defaultValue
          ? _value.defaultValue
          : defaultValue // ignore: cast_nullable_to_non_nullable
              as double?,
      maximumValue: freezed == maximumValue
          ? _value.maximumValue
          : maximumValue // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AttributeModelImpl implements _AttributeModel {
  const _$AttributeModelImpl(
      {this.id,
      this.modelName,
      this.name,
      @freezed this.defaultValue = 0.0,
      this.maximumValue = 0.0});

  factory _$AttributeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttributeModelImplFromJson(json);

  @override
  final String? id;
  @override
  final String? modelName;
  @override
  final String? name;
  @override
  @JsonKey()
  @freezed
  final double? defaultValue;
  @override
  @JsonKey()
  final double? maximumValue;

  @override
  String toString() {
    return 'AttributeModel(id: $id, modelName: $modelName, name: $name, defaultValue: $defaultValue, maximumValue: $maximumValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttributeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.modelName, modelName) ||
                other.modelName == modelName) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.defaultValue, defaultValue) ||
                other.defaultValue == defaultValue) &&
            (identical(other.maximumValue, maximumValue) ||
                other.maximumValue == maximumValue));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, modelName, name, defaultValue, maximumValue);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AttributeModelImplCopyWith<_$AttributeModelImpl> get copyWith =>
      __$$AttributeModelImplCopyWithImpl<_$AttributeModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttributeModelImplToJson(
      this,
    );
  }
}

abstract class _AttributeModel implements AttributeModel {
  const factory _AttributeModel(
      {final String? id,
      final String? modelName,
      final String? name,
      @freezed final double? defaultValue,
      final double? maximumValue}) = _$AttributeModelImpl;

  factory _AttributeModel.fromJson(Map<String, dynamic> json) =
      _$AttributeModelImpl.fromJson;

  @override
  String? get id;
  @override
  String? get modelName;
  @override
  String? get name;
  @override
  @freezed
  double? get defaultValue;
  @override
  double? get maximumValue;
  @override
  @JsonKey(ignore: true)
  _$$AttributeModelImplCopyWith<_$AttributeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
