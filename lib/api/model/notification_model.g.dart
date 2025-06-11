// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Notification _$NotificationFromJson(Map<String, dynamic> json) =>
    _Notification(
      uiName: json['uiName'] as String,
      id: json['id'] as String?,
      variableName: json['variableName'] as String?,
      material: json['material'] as String?,
      frameType:
          $enumDecodeNullable(_$FrameTypeEnumMap, json['frameType']) ??
          FrameType.task,
      title: json['title'] as String?,
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$NotificationToJson(_Notification instance) =>
    <String, dynamic>{
      'uiName': instance.uiName,
      'id': instance.id,
      'variableName': instance.variableName,
      'material': instance.material,
      'frameType': _$FrameTypeEnumMap[instance.frameType]!,
      'title': instance.title,
      'comment': instance.comment,
    };

const _$FrameTypeEnumMap = {
  FrameType.task: 'task',
  FrameType.challenge: 'challenge',
  FrameType.goal: 'goal',
};
