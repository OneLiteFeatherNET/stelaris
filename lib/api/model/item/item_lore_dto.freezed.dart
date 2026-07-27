// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_lore_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemLoreDto {

 String get text; String? get id; int get orderIndex;
/// Create a copy of ItemLoreDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemLoreDtoCopyWith<ItemLoreDto> get copyWith => _$ItemLoreDtoCopyWithImpl<ItemLoreDto>(this as ItemLoreDto, _$identity);

  /// Serializes this ItemLoreDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemLoreDto&&(identical(other.text, text) || other.text == text)&&(identical(other.id, id) || other.id == id)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,id,orderIndex);

@override
String toString() {
  return 'ItemLoreDto(text: $text, id: $id, orderIndex: $orderIndex)';
}


}

/// @nodoc
abstract mixin class $ItemLoreDtoCopyWith<$Res>  {
  factory $ItemLoreDtoCopyWith(ItemLoreDto value, $Res Function(ItemLoreDto) _then) = _$ItemLoreDtoCopyWithImpl;
@useResult
$Res call({
 String text, String? id, int orderIndex
});




}
/// @nodoc
class _$ItemLoreDtoCopyWithImpl<$Res>
    implements $ItemLoreDtoCopyWith<$Res> {
  _$ItemLoreDtoCopyWithImpl(this._self, this._then);

  final ItemLoreDto _self;
  final $Res Function(ItemLoreDto) _then;

/// Create a copy of ItemLoreDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? id = freezed,Object? orderIndex = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemLoreDto].
extension ItemLoreDtoPatterns on ItemLoreDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemLoreDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemLoreDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemLoreDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemLoreDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemLoreDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemLoreDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  String? id,  int orderIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemLoreDto() when $default != null:
return $default(_that.text,_that.id,_that.orderIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  String? id,  int orderIndex)  $default,) {final _that = this;
switch (_that) {
case _ItemLoreDto():
return $default(_that.text,_that.id,_that.orderIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  String? id,  int orderIndex)?  $default,) {final _that = this;
switch (_that) {
case _ItemLoreDto() when $default != null:
return $default(_that.text,_that.id,_that.orderIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemLoreDto extends ItemLoreDto {
  const _ItemLoreDto({required this.text, this.id, this.orderIndex = 0}): super._();
  factory _ItemLoreDto.fromJson(Map<String, dynamic> json) => _$ItemLoreDtoFromJson(json);

@override final  String text;
@override final  String? id;
@override@JsonKey() final  int orderIndex;

/// Create a copy of ItemLoreDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemLoreDtoCopyWith<_ItemLoreDto> get copyWith => __$ItemLoreDtoCopyWithImpl<_ItemLoreDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemLoreDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemLoreDto&&(identical(other.text, text) || other.text == text)&&(identical(other.id, id) || other.id == id)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,id,orderIndex);

@override
String toString() {
  return 'ItemLoreDto(text: $text, id: $id, orderIndex: $orderIndex)';
}


}

/// @nodoc
abstract mixin class _$ItemLoreDtoCopyWith<$Res> implements $ItemLoreDtoCopyWith<$Res> {
  factory _$ItemLoreDtoCopyWith(_ItemLoreDto value, $Res Function(_ItemLoreDto) _then) = __$ItemLoreDtoCopyWithImpl;
@override @useResult
$Res call({
 String text, String? id, int orderIndex
});




}
/// @nodoc
class __$ItemLoreDtoCopyWithImpl<$Res>
    implements _$ItemLoreDtoCopyWith<$Res> {
  __$ItemLoreDtoCopyWithImpl(this._self, this._then);

  final _ItemLoreDto _self;
  final $Res Function(_ItemLoreDto) _then;

/// Create a copy of ItemLoreDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? id = freezed,Object? orderIndex = null,}) {
  return _then(_ItemLoreDto(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
