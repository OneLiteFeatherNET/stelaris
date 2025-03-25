// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Notification _$NotificationFromJson(Map<String, dynamic> json) =>
    _Notification(
      id: json['id'] as String?,
      modelName: json['modelName'] as String?,
      name: json['name'] as String?,
      material: json['material'] as String?,
      frameType: $enumDecodeNullable(_$FrameTypeEnumMap, json['frameType']) ??
          FrameType.task,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$NotificationToJson(_Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelName': instance.modelName,
      'name': instance.name,
      'material': instance.material,
      'frameType': _$FrameTypeEnumMap[instance.frameType]!,
      'title': instance.title,
      'description': instance.description,
    };

const _$FrameTypeEnumMap = {
  FrameType.task: 'task',
  FrameType.challenge: 'challenge',
  FrameType.goal: 'goal',
};
