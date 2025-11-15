// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'build_information.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BuildInformation {

 Map<String, String>? get data;
/// Create a copy of BuildInformation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuildInformationCopyWith<BuildInformation> get copyWith => _$BuildInformationCopyWithImpl<BuildInformation>(this as BuildInformation, _$identity);

  /// Serializes this BuildInformation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuildInformation&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'BuildInformation(data: $data)';
}


}

/// @nodoc
abstract mixin class $BuildInformationCopyWith<$Res>  {
  factory $BuildInformationCopyWith(BuildInformation value, $Res Function(BuildInformation) _then) = _$BuildInformationCopyWithImpl;
@useResult
$Res call({
 Map<String, String>? data
});




}
/// @nodoc
class _$BuildInformationCopyWithImpl<$Res>
    implements $BuildInformationCopyWith<$Res> {
  _$BuildInformationCopyWithImpl(this._self, this._then);

  final BuildInformation _self;
  final $Res Function(BuildInformation) _then;

/// Create a copy of BuildInformation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,}) {
  return _then(_self.copyWith(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [BuildInformation].
extension BuildInformationPatterns on BuildInformation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuildInformation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuildInformation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuildInformation value)  $default,){
final _that = this;
switch (_that) {
case _BuildInformation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuildInformation value)?  $default,){
final _that = this;
switch (_that) {
case _BuildInformation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, String>? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuildInformation() when $default != null:
return $default(_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, String>? data)  $default,) {final _that = this;
switch (_that) {
case _BuildInformation():
return $default(_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, String>? data)?  $default,) {final _that = this;
switch (_that) {
case _BuildInformation() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BuildInformation extends BuildInformation {
  const _BuildInformation({final  Map<String, String>? data}): _data = data,super._();
  factory _BuildInformation.fromJson(Map<String, dynamic> json) => _$BuildInformationFromJson(json);

 final  Map<String, String>? _data;
@override Map<String, String>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of BuildInformation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildInformationCopyWith<_BuildInformation> get copyWith => __$BuildInformationCopyWithImpl<_BuildInformation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuildInformationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildInformation&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'BuildInformation(data: $data)';
}


}

/// @nodoc
abstract mixin class _$BuildInformationCopyWith<$Res> implements $BuildInformationCopyWith<$Res> {
  factory _$BuildInformationCopyWith(_BuildInformation value, $Res Function(_BuildInformation) _then) = __$BuildInformationCopyWithImpl;
@override @useResult
$Res call({
 Map<String, String>? data
});




}
/// @nodoc
class __$BuildInformationCopyWithImpl<$Res>
    implements _$BuildInformationCopyWith<$Res> {
  __$BuildInformationCopyWithImpl(this._self, this._then);

  final _BuildInformation _self;
  final $Res Function(_BuildInformation) _then;

/// Create a copy of BuildInformation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(_BuildInformation(
data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}

// dart format on
