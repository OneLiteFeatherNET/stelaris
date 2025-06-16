// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sound_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SoundEventModel {

 String get uiName; String? get id; String? get variableName; String? get keyName; String? get subTitle; List<SoundFileSource>? get files;
/// Create a copy of SoundEventModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SoundEventModelCopyWith<SoundEventModel> get copyWith => _$SoundEventModelCopyWithImpl<SoundEventModel>(this as SoundEventModel, _$identity);

  /// Serializes this SoundEventModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SoundEventModel&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.id, id) || other.id == id)&&(identical(other.variableName, variableName) || other.variableName == variableName)&&(identical(other.keyName, keyName) || other.keyName == keyName)&&(identical(other.subTitle, subTitle) || other.subTitle == subTitle)&&const DeepCollectionEquality().equals(other.files, files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uiName,id,variableName,keyName,subTitle,const DeepCollectionEquality().hash(files));

@override
String toString() {
  return 'SoundEventModel(uiName: $uiName, id: $id, variableName: $variableName, keyName: $keyName, subTitle: $subTitle, files: $files)';
}


}

/// @nodoc
abstract mixin class $SoundEventModelCopyWith<$Res>  {
  factory $SoundEventModelCopyWith(SoundEventModel value, $Res Function(SoundEventModel) _then) = _$SoundEventModelCopyWithImpl;
@useResult
$Res call({
 String uiName, String? id, String? variableName, String? keyName, String? subTitle, List<SoundFileSource>? files
});




}
/// @nodoc
class _$SoundEventModelCopyWithImpl<$Res>
    implements $SoundEventModelCopyWith<$Res> {
  _$SoundEventModelCopyWithImpl(this._self, this._then);

  final SoundEventModel _self;
  final $Res Function(SoundEventModel) _then;

/// Create a copy of SoundEventModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uiName = null,Object? id = freezed,Object? variableName = freezed,Object? keyName = freezed,Object? subTitle = freezed,Object? files = freezed,}) {
  return _then(_self.copyWith(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,variableName: freezed == variableName ? _self.variableName : variableName // ignore: cast_nullable_to_non_nullable
as String?,keyName: freezed == keyName ? _self.keyName : keyName // ignore: cast_nullable_to_non_nullable
as String?,subTitle: freezed == subTitle ? _self.subTitle : subTitle // ignore: cast_nullable_to_non_nullable
as String?,files: freezed == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<SoundFileSource>?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SoundEventModel extends SoundEventModel {
  const _SoundEventModel({required this.uiName, this.id, this.variableName, this.keyName, this.subTitle, final  List<SoundFileSource>? files = null}): _files = files,super._();
  factory _SoundEventModel.fromJson(Map<String, dynamic> json) => _$SoundEventModelFromJson(json);

@override final  String uiName;
@override final  String? id;
@override final  String? variableName;
@override final  String? keyName;
@override final  String? subTitle;
 final  List<SoundFileSource>? _files;
@override@JsonKey() List<SoundFileSource>? get files {
  final value = _files;
  if (value == null) return null;
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of SoundEventModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SoundEventModelCopyWith<_SoundEventModel> get copyWith => __$SoundEventModelCopyWithImpl<_SoundEventModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SoundEventModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SoundEventModel&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.id, id) || other.id == id)&&(identical(other.variableName, variableName) || other.variableName == variableName)&&(identical(other.keyName, keyName) || other.keyName == keyName)&&(identical(other.subTitle, subTitle) || other.subTitle == subTitle)&&const DeepCollectionEquality().equals(other._files, _files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uiName,id,variableName,keyName,subTitle,const DeepCollectionEquality().hash(_files));

@override
String toString() {
  return 'SoundEventModel(uiName: $uiName, id: $id, variableName: $variableName, keyName: $keyName, subTitle: $subTitle, files: $files)';
}


}

/// @nodoc
abstract mixin class _$SoundEventModelCopyWith<$Res> implements $SoundEventModelCopyWith<$Res> {
  factory _$SoundEventModelCopyWith(_SoundEventModel value, $Res Function(_SoundEventModel) _then) = __$SoundEventModelCopyWithImpl;
@override @useResult
$Res call({
 String uiName, String? id, String? variableName, String? keyName, String? subTitle, List<SoundFileSource>? files
});




}
/// @nodoc
class __$SoundEventModelCopyWithImpl<$Res>
    implements _$SoundEventModelCopyWith<$Res> {
  __$SoundEventModelCopyWithImpl(this._self, this._then);

  final _SoundEventModel _self;
  final $Res Function(_SoundEventModel) _then;

/// Create a copy of SoundEventModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uiName = null,Object? id = freezed,Object? variableName = freezed,Object? keyName = freezed,Object? subTitle = freezed,Object? files = freezed,}) {
  return _then(_SoundEventModel(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,variableName: freezed == variableName ? _self.variableName : variableName // ignore: cast_nullable_to_non_nullable
as String?,keyName: freezed == keyName ? _self.keyName : keyName // ignore: cast_nullable_to_non_nullable
as String?,subTitle: freezed == subTitle ? _self.subTitle : subTitle // ignore: cast_nullable_to_non_nullable
as String?,files: freezed == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<SoundFileSource>?,
  ));
}


}

// dart format on
