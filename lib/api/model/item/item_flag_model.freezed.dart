// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_flag_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemFlagModel {

 String get id; Set<String> get flags;
/// Create a copy of ItemFlagModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemFlagModelCopyWith<ItemFlagModel> get copyWith => _$ItemFlagModelCopyWithImpl<ItemFlagModel>(this as ItemFlagModel, _$identity);

  /// Serializes this ItemFlagModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemFlagModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.flags, flags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(flags));

@override
String toString() {
  return 'ItemFlagModel(id: $id, flags: $flags)';
}


}

/// @nodoc
abstract mixin class $ItemFlagModelCopyWith<$Res>  {
  factory $ItemFlagModelCopyWith(ItemFlagModel value, $Res Function(ItemFlagModel) _then) = _$ItemFlagModelCopyWithImpl;
@useResult
$Res call({
 String id, Set<String> flags
});




}
/// @nodoc
class _$ItemFlagModelCopyWithImpl<$Res>
    implements $ItemFlagModelCopyWith<$Res> {
  _$ItemFlagModelCopyWithImpl(this._self, this._then);

  final ItemFlagModel _self;
  final $Res Function(ItemFlagModel) _then;

/// Create a copy of ItemFlagModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? flags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemFlagModel].
extension ItemFlagModelPatterns on ItemFlagModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemFlagModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemFlagModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemFlagModel value)  $default,){
final _that = this;
switch (_that) {
case _ItemFlagModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemFlagModel value)?  $default,){
final _that = this;
switch (_that) {
case _ItemFlagModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Set<String> flags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemFlagModel() when $default != null:
return $default(_that.id,_that.flags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Set<String> flags)  $default,) {final _that = this;
switch (_that) {
case _ItemFlagModel():
return $default(_that.id,_that.flags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Set<String> flags)?  $default,) {final _that = this;
switch (_that) {
case _ItemFlagModel() when $default != null:
return $default(_that.id,_that.flags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemFlagModel extends ItemFlagModel {
  const _ItemFlagModel({required this.id, required final  Set<String> flags}): _flags = flags,super._();
  factory _ItemFlagModel.fromJson(Map<String, dynamic> json) => _$ItemFlagModelFromJson(json);

@override final  String id;
 final  Set<String> _flags;
@override Set<String> get flags {
  if (_flags is EqualUnmodifiableSetView) return _flags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_flags);
}


/// Create a copy of ItemFlagModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemFlagModelCopyWith<_ItemFlagModel> get copyWith => __$ItemFlagModelCopyWithImpl<_ItemFlagModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemFlagModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemFlagModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._flags, _flags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_flags));

@override
String toString() {
  return 'ItemFlagModel(id: $id, flags: $flags)';
}


}

/// @nodoc
abstract mixin class _$ItemFlagModelCopyWith<$Res> implements $ItemFlagModelCopyWith<$Res> {
  factory _$ItemFlagModelCopyWith(_ItemFlagModel value, $Res Function(_ItemFlagModel) _then) = __$ItemFlagModelCopyWithImpl;
@override @useResult
$Res call({
 String id, Set<String> flags
});




}
/// @nodoc
class __$ItemFlagModelCopyWithImpl<$Res>
    implements _$ItemFlagModelCopyWith<$Res> {
  __$ItemFlagModelCopyWithImpl(this._self, this._then);

  final _ItemFlagModel _self;
  final $Res Function(_ItemFlagModel) _then;

/// Create a copy of ItemFlagModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? flags = null,}) {
  return _then(_ItemFlagModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,flags: null == flags ? _self._flags : flags // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
