// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'font_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FontModel {

 String get uiName; String? get id; String? get variableName; String? get provider; String? get texturePath; String? get comment; String get mapper; int get ascent; int get height; PaginatedResult<FontStringDTO> get chars;@JsonKey(includeToJson: false) bool get isLoadingChars;
/// Create a copy of FontModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FontModelCopyWith<FontModel> get copyWith => _$FontModelCopyWithImpl<FontModel>(this as FontModel, _$identity);

  /// Serializes this FontModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FontModel&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.id, id) || other.id == id)&&(identical(other.variableName, variableName) || other.variableName == variableName)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.texturePath, texturePath) || other.texturePath == texturePath)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.mapper, mapper) || other.mapper == mapper)&&(identical(other.ascent, ascent) || other.ascent == ascent)&&(identical(other.height, height) || other.height == height)&&(identical(other.chars, chars) || other.chars == chars)&&(identical(other.isLoadingChars, isLoadingChars) || other.isLoadingChars == isLoadingChars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uiName,id,variableName,provider,texturePath,comment,mapper,ascent,height,chars,isLoadingChars);

@override
String toString() {
  return 'FontModel(uiName: $uiName, id: $id, variableName: $variableName, provider: $provider, texturePath: $texturePath, comment: $comment, mapper: $mapper, ascent: $ascent, height: $height, chars: $chars, isLoadingChars: $isLoadingChars)';
}


}

/// @nodoc
abstract mixin class $FontModelCopyWith<$Res>  {
  factory $FontModelCopyWith(FontModel value, $Res Function(FontModel) _then) = _$FontModelCopyWithImpl;
@useResult
$Res call({
 String uiName, String? id, String? variableName, String? provider, String? texturePath, String? comment, String mapper, int ascent, int height, PaginatedResult<FontStringDTO> chars,@JsonKey(includeToJson: false) bool isLoadingChars
});




}
/// @nodoc
class _$FontModelCopyWithImpl<$Res>
    implements $FontModelCopyWith<$Res> {
  _$FontModelCopyWithImpl(this._self, this._then);

  final FontModel _self;
  final $Res Function(FontModel) _then;

/// Create a copy of FontModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uiName = null,Object? id = freezed,Object? variableName = freezed,Object? provider = freezed,Object? texturePath = freezed,Object? comment = freezed,Object? mapper = null,Object? ascent = null,Object? height = null,Object? chars = null,Object? isLoadingChars = null,}) {
  return _then(_self.copyWith(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,variableName: freezed == variableName ? _self.variableName : variableName // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,texturePath: freezed == texturePath ? _self.texturePath : texturePath // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,mapper: null == mapper ? _self.mapper : mapper // ignore: cast_nullable_to_non_nullable
as String,ascent: null == ascent ? _self.ascent : ascent // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,chars: null == chars ? _self.chars : chars // ignore: cast_nullable_to_non_nullable
as PaginatedResult<FontStringDTO>,isLoadingChars: null == isLoadingChars ? _self.isLoadingChars : isLoadingChars // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FontModel].
extension FontModelPatterns on FontModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FontModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FontModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FontModel value)  $default,){
final _that = this;
switch (_that) {
case _FontModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FontModel value)?  $default,){
final _that = this;
switch (_that) {
case _FontModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uiName,  String? id,  String? variableName,  String? provider,  String? texturePath,  String? comment,  String mapper,  int ascent,  int height,  PaginatedResult<FontStringDTO> chars, @JsonKey(includeToJson: false)  bool isLoadingChars)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FontModel() when $default != null:
return $default(_that.uiName,_that.id,_that.variableName,_that.provider,_that.texturePath,_that.comment,_that.mapper,_that.ascent,_that.height,_that.chars,_that.isLoadingChars);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uiName,  String? id,  String? variableName,  String? provider,  String? texturePath,  String? comment,  String mapper,  int ascent,  int height,  PaginatedResult<FontStringDTO> chars, @JsonKey(includeToJson: false)  bool isLoadingChars)  $default,) {final _that = this;
switch (_that) {
case _FontModel():
return $default(_that.uiName,_that.id,_that.variableName,_that.provider,_that.texturePath,_that.comment,_that.mapper,_that.ascent,_that.height,_that.chars,_that.isLoadingChars);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uiName,  String? id,  String? variableName,  String? provider,  String? texturePath,  String? comment,  String mapper,  int ascent,  int height,  PaginatedResult<FontStringDTO> chars, @JsonKey(includeToJson: false)  bool isLoadingChars)?  $default,) {final _that = this;
switch (_that) {
case _FontModel() when $default != null:
return $default(_that.uiName,_that.id,_that.variableName,_that.provider,_that.texturePath,_that.comment,_that.mapper,_that.ascent,_that.height,_that.chars,_that.isLoadingChars);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FontModel extends FontModel {
  const _FontModel({required this.uiName, this.id, this.variableName, this.provider, this.texturePath, this.comment, this.mapper = 'font', this.ascent = 0, this.height = 0, this.chars = FontModel._defaultFiles, @JsonKey(includeToJson: false) this.isLoadingChars = false}): super._();
  factory _FontModel.fromJson(Map<String, dynamic> json) => _$FontModelFromJson(json);

@override final  String uiName;
@override final  String? id;
@override final  String? variableName;
@override final  String? provider;
@override final  String? texturePath;
@override final  String? comment;
@override@JsonKey() final  String mapper;
@override@JsonKey() final  int ascent;
@override@JsonKey() final  int height;
@override@JsonKey() final  PaginatedResult<FontStringDTO> chars;
@override@JsonKey(includeToJson: false) final  bool isLoadingChars;

/// Create a copy of FontModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FontModelCopyWith<_FontModel> get copyWith => __$FontModelCopyWithImpl<_FontModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FontModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FontModel&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.id, id) || other.id == id)&&(identical(other.variableName, variableName) || other.variableName == variableName)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.texturePath, texturePath) || other.texturePath == texturePath)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.mapper, mapper) || other.mapper == mapper)&&(identical(other.ascent, ascent) || other.ascent == ascent)&&(identical(other.height, height) || other.height == height)&&(identical(other.chars, chars) || other.chars == chars)&&(identical(other.isLoadingChars, isLoadingChars) || other.isLoadingChars == isLoadingChars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uiName,id,variableName,provider,texturePath,comment,mapper,ascent,height,chars,isLoadingChars);

@override
String toString() {
  return 'FontModel(uiName: $uiName, id: $id, variableName: $variableName, provider: $provider, texturePath: $texturePath, comment: $comment, mapper: $mapper, ascent: $ascent, height: $height, chars: $chars, isLoadingChars: $isLoadingChars)';
}


}

/// @nodoc
abstract mixin class _$FontModelCopyWith<$Res> implements $FontModelCopyWith<$Res> {
  factory _$FontModelCopyWith(_FontModel value, $Res Function(_FontModel) _then) = __$FontModelCopyWithImpl;
@override @useResult
$Res call({
 String uiName, String? id, String? variableName, String? provider, String? texturePath, String? comment, String mapper, int ascent, int height, PaginatedResult<FontStringDTO> chars,@JsonKey(includeToJson: false) bool isLoadingChars
});




}
/// @nodoc
class __$FontModelCopyWithImpl<$Res>
    implements _$FontModelCopyWith<$Res> {
  __$FontModelCopyWithImpl(this._self, this._then);

  final _FontModel _self;
  final $Res Function(_FontModel) _then;

/// Create a copy of FontModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uiName = null,Object? id = freezed,Object? variableName = freezed,Object? provider = freezed,Object? texturePath = freezed,Object? comment = freezed,Object? mapper = null,Object? ascent = null,Object? height = null,Object? chars = null,Object? isLoadingChars = null,}) {
  return _then(_FontModel(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,variableName: freezed == variableName ? _self.variableName : variableName // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,texturePath: freezed == texturePath ? _self.texturePath : texturePath // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,mapper: null == mapper ? _self.mapper : mapper // ignore: cast_nullable_to_non_nullable
as String,ascent: null == ascent ? _self.ascent : ascent // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,chars: null == chars ? _self.chars : chars // ignore: cast_nullable_to_non_nullable
as PaginatedResult<FontStringDTO>,isLoadingChars: null == isLoadingChars ? _self.isLoadingChars : isLoadingChars // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
