// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'build_information.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BuildInformation _$BuildInformationFromJson(Map<String, dynamic> json) {
  return _BuildInformation.fromJson(json);
}

/// @nodoc
mixin _$BuildInformation {
  Map<String, String>? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BuildInformationCopyWith<BuildInformation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuildInformationCopyWith<$Res> {
  factory $BuildInformationCopyWith(
          BuildInformation value, $Res Function(BuildInformation) then) =
      _$BuildInformationCopyWithImpl<$Res, BuildInformation>;
  @useResult
  $Res call({Map<String, String>? data});
}

/// @nodoc
class _$BuildInformationCopyWithImpl<$Res, $Val extends BuildInformation>
    implements $BuildInformationCopyWith<$Res> {
  _$BuildInformationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BuildInformationImplCopyWith<$Res>
    implements $BuildInformationCopyWith<$Res> {
  factory _$$BuildInformationImplCopyWith(_$BuildInformationImpl value,
          $Res Function(_$BuildInformationImpl) then) =
      __$$BuildInformationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, String>? data});
}

/// @nodoc
class __$$BuildInformationImplCopyWithImpl<$Res>
    extends _$BuildInformationCopyWithImpl<$Res, _$BuildInformationImpl>
    implements _$$BuildInformationImplCopyWith<$Res> {
  __$$BuildInformationImplCopyWithImpl(_$BuildInformationImpl _value,
      $Res Function(_$BuildInformationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
  }) {
    return _then(_$BuildInformationImpl(
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BuildInformationImpl implements _BuildInformation {
  const _$BuildInformationImpl({final Map<String, String>? data})
      : _data = data;

  factory _$BuildInformationImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuildInformationImplFromJson(json);

  final Map<String, String>? _data;
  @override
  Map<String, String>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'BuildInformation(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuildInformationImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BuildInformationImplCopyWith<_$BuildInformationImpl> get copyWith =>
      __$$BuildInformationImplCopyWithImpl<_$BuildInformationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BuildInformationImplToJson(
      this,
    );
  }
}

abstract class _BuildInformation implements BuildInformation {
  const factory _BuildInformation({final Map<String, String>? data}) =
      _$BuildInformationImpl;

  factory _BuildInformation.fromJson(Map<String, dynamic> json) =
      _$BuildInformationImpl.fromJson;

  @override
  Map<String, String>? get data;
  @override
  @JsonKey(ignore: true)
  _$$BuildInformationImplCopyWith<_$BuildInformationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
