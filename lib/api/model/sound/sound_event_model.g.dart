// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SoundEventModel _$SoundEventModelFromJson(Map<String, dynamic> json) =>
    _SoundEventModel(
      uiName: json['uiName'] as String,
      id: json['id'] as String?,
      variableName: json['variableName'] as String?,
      keyName: json['keyName'] as String?,
      subTitle: json['subTitle'] as String?,
    );

Map<String, dynamic> _$SoundEventModelToJson(_SoundEventModel instance) =>
    <String, dynamic>{
      'uiName': instance.uiName,
      'id': instance.id,
      'variableName': instance.variableName,
      'keyName': instance.keyName,
      'subTitle': instance.subTitle,
    };
