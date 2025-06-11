// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attribute_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttributeModel {

 String get uiName; String? get id; String? get variableName;@freezed double? get defaultValue; double? get maximumValue;
/// Create a copy of AttributeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttributeModelCopyWith<AttributeModel> get copyWith => _$AttributeModelCopyWithImpl<AttributeModel>(this as AttributeModel, _$identity);

  /// Serializes this AttributeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttributeModel&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.id, id) || other.id == id)&&(identical(other.variableName, variableName) || other.variableName == variableName)&&(identical(other.defaultValue, defaultValue) || other.defaultValue == defaultValue)&&(identical(other.maximumValue, maximumValue) || other.maximumValue == maximumValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uiName,id,variableName,defaultValue,maximumValue);

@override
String toString() {
  return 'AttributeModel(uiName: $uiName, id: $id, variableName: $variableName, defaultValue: $defaultValue, maximumValue: $maximumValue)';
}


}

/// @nodoc
abstract mixin class $AttributeModelCopyWith<$Res>  {
  factory $AttributeModelCopyWith(AttributeModel value, $Res Function(AttributeModel) _then) = _$AttributeModelCopyWithImpl;
@useResult
$Res call({
 String uiName, String? id, String? variableName,@freezed double? defaultValue, double? maximumValue
});




}
/// @nodoc
class _$AttributeModelCopyWithImpl<$Res>
    implements $AttributeModelCopyWith<$Res> {
  _$AttributeModelCopyWithImpl(this._self, this._then);

  final AttributeModel _self;
  final $Res Function(AttributeModel) _then;

/// Create a copy of AttributeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uiName = null,Object? id = freezed,Object? variableName = freezed,Object? defaultValue = freezed,Object? maximumValue = freezed,}) {
  return _then(_self.copyWith(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,variableName: freezed == variableName ? _self.variableName : variableName // ignore: cast_nullable_to_non_nullable
as String?,defaultValue: freezed == defaultValue ? _self.defaultValue : defaultValue // ignore: cast_nullable_to_non_nullable
as double?,maximumValue: freezed == maximumValue ? _self.maximumValue : maximumValue // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _AttributeModel extends AttributeModel {
  const _AttributeModel({required this.uiName, this.id, this.variableName, @freezed this.defaultValue = 0.0, this.maximumValue = 0.0}): super._();
  factory _AttributeModel.fromJson(Map<String, dynamic> json) => _$AttributeModelFromJson(json);

@override final  String uiName;
@override final  String? id;
@override final  String? variableName;
@override@JsonKey()@freezed final  double? defaultValue;
@override@JsonKey() final  double? maximumValue;

/// Create a copy of AttributeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttributeModelCopyWith<_AttributeModel> get copyWith => __$AttributeModelCopyWithImpl<_AttributeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttributeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttributeModel&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.id, id) || other.id == id)&&(identical(other.variableName, variableName) || other.variableName == variableName)&&(identical(other.defaultValue, defaultValue) || other.defaultValue == defaultValue)&&(identical(other.maximumValue, maximumValue) || other.maximumValue == maximumValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uiName,id,variableName,defaultValue,maximumValue);

@override
String toString() {
  return 'AttributeModel(uiName: $uiName, id: $id, variableName: $variableName, defaultValue: $defaultValue, maximumValue: $maximumValue)';
}


}

/// @nodoc
abstract mixin class _$AttributeModelCopyWith<$Res> implements $AttributeModelCopyWith<$Res> {
  factory _$AttributeModelCopyWith(_AttributeModel value, $Res Function(_AttributeModel) _then) = __$AttributeModelCopyWithImpl;
@override @useResult
$Res call({
 String uiName, String? id, String? variableName,@freezed double? defaultValue, double? maximumValue
});




}
/// @nodoc
class __$AttributeModelCopyWithImpl<$Res>
    implements _$AttributeModelCopyWith<$Res> {
  __$AttributeModelCopyWithImpl(this._self, this._then);

  final _AttributeModel _self;
  final $Res Function(_AttributeModel) _then;

/// Create a copy of AttributeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uiName = null,Object? id = freezed,Object? variableName = freezed,Object? defaultValue = freezed,Object? maximumValue = freezed,}) {
  return _then(_AttributeModel(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,variableName: freezed == variableName ? _self.variableName : variableName // ignore: cast_nullable_to_non_nullable
as String?,defaultValue: freezed == defaultValue ? _self.defaultValue : defaultValue // ignore: cast_nullable_to_non_nullable
as double?,maximumValue: freezed == maximumValue ? _self.maximumValue : maximumValue // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
