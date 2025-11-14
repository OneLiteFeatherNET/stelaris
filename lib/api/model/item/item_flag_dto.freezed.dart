// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_flag_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemFlagDto {

 String get id; String get flag;
/// Create a copy of ItemFlagDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemFlagDtoCopyWith<ItemFlagDto> get copyWith => _$ItemFlagDtoCopyWithImpl<ItemFlagDto>(this as ItemFlagDto, _$identity);

  /// Serializes this ItemFlagDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemFlagDto&&(identical(other.id, id) || other.id == id)&&(identical(other.flag, flag) || other.flag == flag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,flag);

@override
String toString() {
  return 'ItemFlagDto(id: $id, flag: $flag)';
}


}

/// @nodoc
abstract mixin class $ItemFlagDtoCopyWith<$Res>  {
  factory $ItemFlagDtoCopyWith(ItemFlagDto value, $Res Function(ItemFlagDto) _then) = _$ItemFlagDtoCopyWithImpl;
@useResult
$Res call({
 String id, String flag
});




}
/// @nodoc
class _$ItemFlagDtoCopyWithImpl<$Res>
    implements $ItemFlagDtoCopyWith<$Res> {
  _$ItemFlagDtoCopyWithImpl(this._self, this._then);

  final ItemFlagDto _self;
  final $Res Function(ItemFlagDto) _then;

/// Create a copy of ItemFlagDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? flag = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,flag: null == flag ? _self.flag : flag // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemFlagDto].
extension ItemFlagDtoPatterns on ItemFlagDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemFlagDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemFlagDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemFlagDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemFlagDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemFlagDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemFlagDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String flag)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemFlagDto() when $default != null:
return $default(_that.id,_that.flag);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String flag)  $default,) {final _that = this;
switch (_that) {
case _ItemFlagDto():
return $default(_that.id,_that.flag);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String flag)?  $default,) {final _that = this;
switch (_that) {
case _ItemFlagDto() when $default != null:
return $default(_that.id,_that.flag);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemFlagDto extends ItemFlagDto {
  const _ItemFlagDto({required this.id, required this.flag}): super._();
  factory _ItemFlagDto.fromJson(Map<String, dynamic> json) => _$ItemFlagDtoFromJson(json);

@override final  String id;
@override final  String flag;

/// Create a copy of ItemFlagDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemFlagDtoCopyWith<_ItemFlagDto> get copyWith => __$ItemFlagDtoCopyWithImpl<_ItemFlagDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemFlagDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemFlagDto&&(identical(other.id, id) || other.id == id)&&(identical(other.flag, flag) || other.flag == flag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,flag);

@override
String toString() {
  return 'ItemFlagDto(id: $id, flag: $flag)';
}


}

/// @nodoc
abstract mixin class _$ItemFlagDtoCopyWith<$Res> implements $ItemFlagDtoCopyWith<$Res> {
  factory _$ItemFlagDtoCopyWith(_ItemFlagDto value, $Res Function(_ItemFlagDto) _then) = __$ItemFlagDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String flag
});




}
/// @nodoc
class __$ItemFlagDtoCopyWithImpl<$Res>
    implements _$ItemFlagDtoCopyWith<$Res> {
  __$ItemFlagDtoCopyWithImpl(this._self, this._then);

  final _ItemFlagDto _self;
  final $Res Function(_ItemFlagDto) _then;

/// Create a copy of ItemFlagDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? flag = null,}) {
  return _then(_ItemFlagDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,flag: null == flag ? _self.flag : flag // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
