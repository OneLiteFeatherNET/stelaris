// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
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

 String? get id; String get uiName; String? get variableName; String? get provider; String? get texturePath; String? get comment; String get mapper; int get ascent; int get height; List<String> get chars;
/// Create a copy of FontModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FontModelCopyWith<FontModel> get copyWith => _$FontModelCopyWithImpl<FontModel>(this as FontModel, _$identity);

  /// Serializes this FontModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FontModel&&(identical(other.id, id) || other.id == id)&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.variableName, variableName) || other.variableName == variableName)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.texturePath, texturePath) || other.texturePath == texturePath)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.mapper, mapper) || other.mapper == mapper)&&(identical(other.ascent, ascent) || other.ascent == ascent)&&(identical(other.height, height) || other.height == height)&&const DeepCollectionEquality().equals(other.chars, chars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uiName,variableName,provider,texturePath,comment,mapper,ascent,height,const DeepCollectionEquality().hash(chars));

@override
String toString() {
  return 'FontModel(id: $id, uiName: $uiName, variableName: $variableName, provider: $provider, texturePath: $texturePath, comment: $comment, mapper: $mapper, ascent: $ascent, height: $height, chars: $chars)';
}


}

/// @nodoc
abstract mixin class $FontModelCopyWith<$Res>  {
  factory $FontModelCopyWith(FontModel value, $Res Function(FontModel) _then) = _$FontModelCopyWithImpl;
@useResult
$Res call({
 String? id, String uiName, String? variableName, String? provider, String? texturePath, String? comment, String mapper, int ascent, int height, List<String> chars
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? uiName = null,Object? variableName = freezed,Object? provider = freezed,Object? texturePath = freezed,Object? comment = freezed,Object? mapper = null,Object? ascent = null,Object? height = null,Object? chars = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,variableName: freezed == variableName ? _self.variableName : variableName // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,texturePath: freezed == texturePath ? _self.texturePath : texturePath // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,mapper: null == mapper ? _self.mapper : mapper // ignore: cast_nullable_to_non_nullable
as String,ascent: null == ascent ? _self.ascent : ascent // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,chars: null == chars ? _self.chars : chars // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _FontModel extends FontModel {
  const _FontModel({this.id, required this.uiName, this.variableName, this.provider, this.texturePath, this.comment, this.mapper = 'font', this.ascent = 0, this.height = 0, final  List<String> chars = const []}): _chars = chars,super._();
  factory _FontModel.fromJson(Map<String, dynamic> json) => _$FontModelFromJson(json);

@override final  String? id;
@override final  String uiName;
@override final  String? variableName;
@override final  String? provider;
@override final  String? texturePath;
@override final  String? comment;
@override@JsonKey() final  String mapper;
@override@JsonKey() final  int ascent;
@override@JsonKey() final  int height;
 final  List<String> _chars;
@override@JsonKey() List<String> get chars {
  if (_chars is EqualUnmodifiableListView) return _chars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chars);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FontModel&&(identical(other.id, id) || other.id == id)&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.variableName, variableName) || other.variableName == variableName)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.texturePath, texturePath) || other.texturePath == texturePath)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.mapper, mapper) || other.mapper == mapper)&&(identical(other.ascent, ascent) || other.ascent == ascent)&&(identical(other.height, height) || other.height == height)&&const DeepCollectionEquality().equals(other._chars, _chars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uiName,variableName,provider,texturePath,comment,mapper,ascent,height,const DeepCollectionEquality().hash(_chars));

@override
String toString() {
  return 'FontModel(id: $id, uiName: $uiName, variableName: $variableName, provider: $provider, texturePath: $texturePath, comment: $comment, mapper: $mapper, ascent: $ascent, height: $height, chars: $chars)';
}


}

/// @nodoc
abstract mixin class _$FontModelCopyWith<$Res> implements $FontModelCopyWith<$Res> {
  factory _$FontModelCopyWith(_FontModel value, $Res Function(_FontModel) _then) = __$FontModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String uiName, String? variableName, String? provider, String? texturePath, String? comment, String mapper, int ascent, int height, List<String> chars
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? uiName = null,Object? variableName = freezed,Object? provider = freezed,Object? texturePath = freezed,Object? comment = freezed,Object? mapper = null,Object? ascent = null,Object? height = null,Object? chars = null,}) {
  return _then(_FontModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,variableName: freezed == variableName ? _self.variableName : variableName // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,texturePath: freezed == texturePath ? _self.texturePath : texturePath // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,mapper: null == mapper ? _self.mapper : mapper // ignore: cast_nullable_to_non_nullable
as String,ascent: null == ascent ? _self.ascent : ascent // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,chars: null == chars ? _self._chars : chars // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
