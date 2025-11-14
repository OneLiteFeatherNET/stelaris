// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_enchantment_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemEnchantmentDto {

 String get id; String get name; int get level;
/// Create a copy of ItemEnchantmentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemEnchantmentDtoCopyWith<ItemEnchantmentDto> get copyWith => _$ItemEnchantmentDtoCopyWithImpl<ItemEnchantmentDto>(this as ItemEnchantmentDto, _$identity);

  /// Serializes this ItemEnchantmentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemEnchantmentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,level);

@override
String toString() {
  return 'ItemEnchantmentDto(id: $id, name: $name, level: $level)';
}


}

/// @nodoc
abstract mixin class $ItemEnchantmentDtoCopyWith<$Res>  {
  factory $ItemEnchantmentDtoCopyWith(ItemEnchantmentDto value, $Res Function(ItemEnchantmentDto) _then) = _$ItemEnchantmentDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, int level
});




}
/// @nodoc
class _$ItemEnchantmentDtoCopyWithImpl<$Res>
    implements $ItemEnchantmentDtoCopyWith<$Res> {
  _$ItemEnchantmentDtoCopyWithImpl(this._self, this._then);

  final ItemEnchantmentDto _self;
  final $Res Function(ItemEnchantmentDto) _then;

/// Create a copy of ItemEnchantmentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? level = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemEnchantmentDto].
extension ItemEnchantmentDtoPatterns on ItemEnchantmentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemEnchantmentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemEnchantmentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemEnchantmentDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemEnchantmentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemEnchantmentDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemEnchantmentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int level)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemEnchantmentDto() when $default != null:
return $default(_that.id,_that.name,_that.level);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int level)  $default,) {final _that = this;
switch (_that) {
case _ItemEnchantmentDto():
return $default(_that.id,_that.name,_that.level);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int level)?  $default,) {final _that = this;
switch (_that) {
case _ItemEnchantmentDto() when $default != null:
return $default(_that.id,_that.name,_that.level);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemEnchantmentDto extends ItemEnchantmentDto {
  const _ItemEnchantmentDto({required this.id, required this.name, required this.level}): super._();
  factory _ItemEnchantmentDto.fromJson(Map<String, dynamic> json) => _$ItemEnchantmentDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  int level;

/// Create a copy of ItemEnchantmentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemEnchantmentDtoCopyWith<_ItemEnchantmentDto> get copyWith => __$ItemEnchantmentDtoCopyWithImpl<_ItemEnchantmentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemEnchantmentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemEnchantmentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,level);

@override
String toString() {
  return 'ItemEnchantmentDto(id: $id, name: $name, level: $level)';
}


}

/// @nodoc
abstract mixin class _$ItemEnchantmentDtoCopyWith<$Res> implements $ItemEnchantmentDtoCopyWith<$Res> {
  factory _$ItemEnchantmentDtoCopyWith(_ItemEnchantmentDto value, $Res Function(_ItemEnchantmentDto) _then) = __$ItemEnchantmentDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int level
});




}
/// @nodoc
class __$ItemEnchantmentDtoCopyWithImpl<$Res>
    implements _$ItemEnchantmentDtoCopyWith<$Res> {
  __$ItemEnchantmentDtoCopyWithImpl(this._self, this._then);

  final _ItemEnchantmentDto _self;
  final $Res Function(_ItemEnchantmentDto) _then;

/// Create a copy of ItemEnchantmentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? level = null,}) {
  return _then(_ItemEnchantmentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
