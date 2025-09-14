// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_enchantment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemEnchantmentModel {

 String get id; Map<String, int> get enchantments;
/// Create a copy of ItemEnchantmentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemEnchantmentModelCopyWith<ItemEnchantmentModel> get copyWith => _$ItemEnchantmentModelCopyWithImpl<ItemEnchantmentModel>(this as ItemEnchantmentModel, _$identity);

  /// Serializes this ItemEnchantmentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemEnchantmentModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.enchantments, enchantments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(enchantments));

@override
String toString() {
  return 'ItemEnchantmentModel(id: $id, enchantments: $enchantments)';
}


}

/// @nodoc
abstract mixin class $ItemEnchantmentModelCopyWith<$Res>  {
  factory $ItemEnchantmentModelCopyWith(ItemEnchantmentModel value, $Res Function(ItemEnchantmentModel) _then) = _$ItemEnchantmentModelCopyWithImpl;
@useResult
$Res call({
 String id, Map<String, int> enchantments
});




}
/// @nodoc
class _$ItemEnchantmentModelCopyWithImpl<$Res>
    implements $ItemEnchantmentModelCopyWith<$Res> {
  _$ItemEnchantmentModelCopyWithImpl(this._self, this._then);

  final ItemEnchantmentModel _self;
  final $Res Function(ItemEnchantmentModel) _then;

/// Create a copy of ItemEnchantmentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? enchantments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,enchantments: null == enchantments ? _self.enchantments : enchantments // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemEnchantmentModel].
extension ItemEnchantmentModelPatterns on ItemEnchantmentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemEnchantmentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemEnchantmentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemEnchantmentModel value)  $default,){
final _that = this;
switch (_that) {
case _ItemEnchantmentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemEnchantmentModel value)?  $default,){
final _that = this;
switch (_that) {
case _ItemEnchantmentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Map<String, int> enchantments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemEnchantmentModel() when $default != null:
return $default(_that.id,_that.enchantments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Map<String, int> enchantments)  $default,) {final _that = this;
switch (_that) {
case _ItemEnchantmentModel():
return $default(_that.id,_that.enchantments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Map<String, int> enchantments)?  $default,) {final _that = this;
switch (_that) {
case _ItemEnchantmentModel() when $default != null:
return $default(_that.id,_that.enchantments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemEnchantmentModel extends ItemEnchantmentModel {
  const _ItemEnchantmentModel({required this.id, required final  Map<String, int> enchantments}): _enchantments = enchantments,super._();
  factory _ItemEnchantmentModel.fromJson(Map<String, dynamic> json) => _$ItemEnchantmentModelFromJson(json);

@override final  String id;
 final  Map<String, int> _enchantments;
@override Map<String, int> get enchantments {
  if (_enchantments is EqualUnmodifiableMapView) return _enchantments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_enchantments);
}


/// Create a copy of ItemEnchantmentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemEnchantmentModelCopyWith<_ItemEnchantmentModel> get copyWith => __$ItemEnchantmentModelCopyWithImpl<_ItemEnchantmentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemEnchantmentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemEnchantmentModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._enchantments, _enchantments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_enchantments));

@override
String toString() {
  return 'ItemEnchantmentModel(id: $id, enchantments: $enchantments)';
}


}

/// @nodoc
abstract mixin class _$ItemEnchantmentModelCopyWith<$Res> implements $ItemEnchantmentModelCopyWith<$Res> {
  factory _$ItemEnchantmentModelCopyWith(_ItemEnchantmentModel value, $Res Function(_ItemEnchantmentModel) _then) = __$ItemEnchantmentModelCopyWithImpl;
@override @useResult
$Res call({
 String id, Map<String, int> enchantments
});




}
/// @nodoc
class __$ItemEnchantmentModelCopyWithImpl<$Res>
    implements _$ItemEnchantmentModelCopyWith<$Res> {
  __$ItemEnchantmentModelCopyWithImpl(this._self, this._then);

  final _ItemEnchantmentModel _self;
  final $Res Function(_ItemEnchantmentModel) _then;

/// Create a copy of ItemEnchantmentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? enchantments = null,}) {
  return _then(_ItemEnchantmentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,enchantments: null == enchantments ? _self._enchantments : enchantments // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
