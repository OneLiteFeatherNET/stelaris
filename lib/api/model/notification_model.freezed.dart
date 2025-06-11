// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
NotificationModel _$NotificationModelFromJson(
  Map<String, dynamic> json
) {
    return _Notification.fromJson(
      json
    );
}

/// @nodoc
mixin _$NotificationModel {

 String get uiName; String? get id; String? get variableName; String? get material; FrameType get frameType; String? get title; String? get comment;
/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationModelCopyWith<NotificationModel> get copyWith => _$NotificationModelCopyWithImpl<NotificationModel>(this as NotificationModel, _$identity);

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationModel&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.id, id) || other.id == id)&&(identical(other.variableName, variableName) || other.variableName == variableName)&&(identical(other.material, material) || other.material == material)&&(identical(other.frameType, frameType) || other.frameType == frameType)&&(identical(other.title, title) || other.title == title)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uiName,id,variableName,material,frameType,title,comment);

@override
String toString() {
  return 'NotificationModel(uiName: $uiName, id: $id, variableName: $variableName, material: $material, frameType: $frameType, title: $title, comment: $comment)';
}


}

/// @nodoc
abstract mixin class $NotificationModelCopyWith<$Res>  {
  factory $NotificationModelCopyWith(NotificationModel value, $Res Function(NotificationModel) _then) = _$NotificationModelCopyWithImpl;
@useResult
$Res call({
 String uiName, String? id, String? variableName, String? material, FrameType frameType, String? title, String? comment
});




}
/// @nodoc
class _$NotificationModelCopyWithImpl<$Res>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._self, this._then);

  final NotificationModel _self;
  final $Res Function(NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uiName = null,Object? id = freezed,Object? variableName = freezed,Object? material = freezed,Object? frameType = null,Object? title = freezed,Object? comment = freezed,}) {
  return _then(_self.copyWith(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,variableName: freezed == variableName ? _self.variableName : variableName // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,frameType: null == frameType ? _self.frameType : frameType // ignore: cast_nullable_to_non_nullable
as FrameType,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Notification extends NotificationModel {
  const _Notification({required this.uiName, this.id, this.variableName, this.material, this.frameType = FrameType.task, this.title, this.comment}): super._();
  factory _Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);

@override final  String uiName;
@override final  String? id;
@override final  String? variableName;
@override final  String? material;
@override@JsonKey() final  FrameType frameType;
@override final  String? title;
@override final  String? comment;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationCopyWith<_Notification> get copyWith => __$NotificationCopyWithImpl<_Notification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Notification&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.id, id) || other.id == id)&&(identical(other.variableName, variableName) || other.variableName == variableName)&&(identical(other.material, material) || other.material == material)&&(identical(other.frameType, frameType) || other.frameType == frameType)&&(identical(other.title, title) || other.title == title)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uiName,id,variableName,material,frameType,title,comment);

@override
String toString() {
  return 'NotificationModel(uiName: $uiName, id: $id, variableName: $variableName, material: $material, frameType: $frameType, title: $title, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$NotificationCopyWith<$Res> implements $NotificationModelCopyWith<$Res> {
  factory _$NotificationCopyWith(_Notification value, $Res Function(_Notification) _then) = __$NotificationCopyWithImpl;
@override @useResult
$Res call({
 String uiName, String? id, String? variableName, String? material, FrameType frameType, String? title, String? comment
});




}
/// @nodoc
class __$NotificationCopyWithImpl<$Res>
    implements _$NotificationCopyWith<$Res> {
  __$NotificationCopyWithImpl(this._self, this._then);

  final _Notification _self;
  final $Res Function(_Notification) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uiName = null,Object? id = freezed,Object? variableName = freezed,Object? material = freezed,Object? frameType = null,Object? title = freezed,Object? comment = freezed,}) {
  return _then(_Notification(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,variableName: freezed == variableName ? _self.variableName : variableName // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,frameType: null == frameType ? _self.frameType : frameType // ignore: cast_nullable_to_non_nullable
as FrameType,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
