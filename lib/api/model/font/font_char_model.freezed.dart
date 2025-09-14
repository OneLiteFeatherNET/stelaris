// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'font_char_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FontCharModel {

 String get id; List<String> get chars;
/// Create a copy of FontCharModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FontCharModelCopyWith<FontCharModel> get copyWith => _$FontCharModelCopyWithImpl<FontCharModel>(this as FontCharModel, _$identity);

  /// Serializes this FontCharModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FontCharModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.chars, chars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(chars));

@override
String toString() {
  return 'FontCharModel(id: $id, chars: $chars)';
}


}

/// @nodoc
abstract mixin class $FontCharModelCopyWith<$Res>  {
  factory $FontCharModelCopyWith(FontCharModel value, $Res Function(FontCharModel) _then) = _$FontCharModelCopyWithImpl;
@useResult
$Res call({
 String id, List<String> chars
});




}
/// @nodoc
class _$FontCharModelCopyWithImpl<$Res>
    implements $FontCharModelCopyWith<$Res> {
  _$FontCharModelCopyWithImpl(this._self, this._then);

  final FontCharModel _self;
  final $Res Function(FontCharModel) _then;

/// Create a copy of FontCharModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chars = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chars: null == chars ? _self.chars : chars // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [FontCharModel].
extension FontCharModelPatterns on FontCharModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FontCharModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FontCharModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FontCharModel value)  $default,){
final _that = this;
switch (_that) {
case _FontCharModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FontCharModel value)?  $default,){
final _that = this;
switch (_that) {
case _FontCharModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<String> chars)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FontCharModel() when $default != null:
return $default(_that.id,_that.chars);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<String> chars)  $default,) {final _that = this;
switch (_that) {
case _FontCharModel():
return $default(_that.id,_that.chars);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<String> chars)?  $default,) {final _that = this;
switch (_that) {
case _FontCharModel() when $default != null:
return $default(_that.id,_that.chars);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FontCharModel extends FontCharModel {
  const _FontCharModel({required this.id, required final  List<String> chars}): _chars = chars,super._();
  factory _FontCharModel.fromJson(Map<String, dynamic> json) => _$FontCharModelFromJson(json);

@override final  String id;
 final  List<String> _chars;
@override List<String> get chars {
  if (_chars is EqualUnmodifiableListView) return _chars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chars);
}


/// Create a copy of FontCharModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FontCharModelCopyWith<_FontCharModel> get copyWith => __$FontCharModelCopyWithImpl<_FontCharModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FontCharModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FontCharModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._chars, _chars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_chars));

@override
String toString() {
  return 'FontCharModel(id: $id, chars: $chars)';
}


}

/// @nodoc
abstract mixin class _$FontCharModelCopyWith<$Res> implements $FontCharModelCopyWith<$Res> {
  factory _$FontCharModelCopyWith(_FontCharModel value, $Res Function(_FontCharModel) _then) = __$FontCharModelCopyWithImpl;
@override @useResult
$Res call({
 String id, List<String> chars
});




}
/// @nodoc
class __$FontCharModelCopyWithImpl<$Res>
    implements _$FontCharModelCopyWith<$Res> {
  __$FontCharModelCopyWithImpl(this._self, this._then);

  final _FontCharModel _self;
  final $Res Function(_FontCharModel) _then;

/// Create a copy of FontCharModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chars = null,}) {
  return _then(_FontCharModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chars: null == chars ? _self._chars : chars // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
