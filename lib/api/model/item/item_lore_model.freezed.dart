// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_lore_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemLoreModel {

 String get id; List<String> get lore;
/// Create a copy of ItemLoreModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemLoreModelCopyWith<ItemLoreModel> get copyWith => _$ItemLoreModelCopyWithImpl<ItemLoreModel>(this as ItemLoreModel, _$identity);

  /// Serializes this ItemLoreModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemLoreModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.lore, lore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(lore));

@override
String toString() {
  return 'ItemLoreModel(id: $id, lore: $lore)';
}


}

/// @nodoc
abstract mixin class $ItemLoreModelCopyWith<$Res>  {
  factory $ItemLoreModelCopyWith(ItemLoreModel value, $Res Function(ItemLoreModel) _then) = _$ItemLoreModelCopyWithImpl;
@useResult
$Res call({
 String id, List<String> lore
});




}
/// @nodoc
class _$ItemLoreModelCopyWithImpl<$Res>
    implements $ItemLoreModelCopyWith<$Res> {
  _$ItemLoreModelCopyWithImpl(this._self, this._then);

  final ItemLoreModel _self;
  final $Res Function(ItemLoreModel) _then;

/// Create a copy of ItemLoreModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lore = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lore: null == lore ? _self.lore : lore // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemLoreModel].
extension ItemLoreModelPatterns on ItemLoreModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemLoreModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemLoreModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemLoreModel value)  $default,){
final _that = this;
switch (_that) {
case _ItemLoreModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemLoreModel value)?  $default,){
final _that = this;
switch (_that) {
case _ItemLoreModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<String> lore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemLoreModel() when $default != null:
return $default(_that.id,_that.lore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<String> lore)  $default,) {final _that = this;
switch (_that) {
case _ItemLoreModel():
return $default(_that.id,_that.lore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<String> lore)?  $default,) {final _that = this;
switch (_that) {
case _ItemLoreModel() when $default != null:
return $default(_that.id,_that.lore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemLoreModel extends ItemLoreModel {
  const _ItemLoreModel({required this.id, required final  List<String> lore}): _lore = lore,super._();
  factory _ItemLoreModel.fromJson(Map<String, dynamic> json) => _$ItemLoreModelFromJson(json);

@override final  String id;
 final  List<String> _lore;
@override List<String> get lore {
  if (_lore is EqualUnmodifiableListView) return _lore;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lore);
}


/// Create a copy of ItemLoreModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemLoreModelCopyWith<_ItemLoreModel> get copyWith => __$ItemLoreModelCopyWithImpl<_ItemLoreModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemLoreModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemLoreModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._lore, _lore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_lore));

@override
String toString() {
  return 'ItemLoreModel(id: $id, lore: $lore)';
}


}

/// @nodoc
abstract mixin class _$ItemLoreModelCopyWith<$Res> implements $ItemLoreModelCopyWith<$Res> {
  factory _$ItemLoreModelCopyWith(_ItemLoreModel value, $Res Function(_ItemLoreModel) _then) = __$ItemLoreModelCopyWithImpl;
@override @useResult
$Res call({
 String id, List<String> lore
});




}
/// @nodoc
class __$ItemLoreModelCopyWithImpl<$Res>
    implements _$ItemLoreModelCopyWith<$Res> {
  __$ItemLoreModelCopyWithImpl(this._self, this._then);

  final _ItemLoreModel _self;
  final $Res Function(_ItemLoreModel) _then;

/// Create a copy of ItemLoreModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lore = null,}) {
  return _then(_ItemLoreModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lore: null == lore ? _self._lore : lore // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
