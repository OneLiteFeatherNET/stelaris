// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_model_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FontModelDto _$FontModelDtoFromJson(Map<String, dynamic> json) =>
    _FontModelDto(
      uiName: json['uiName'] as String,
      id: json['id'] as String?,
      variableName: json['variableName'] as String?,
      provider: json['provider'] as String?,
      texturePath: json['texturePath'] as String?,
      comment: json['comment'] as String?,
      mapper: json['mapper'] as String? ?? 'font',
      ascent: (json['ascent'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$FontModelDtoToJson(_FontModelDto instance) =>
    <String, dynamic>{
      'uiName': instance.uiName,
      'id': instance.id,
      'variableName': instance.variableName,
      'provider': instance.provider,
      'texturePath': instance.texturePath,
      'comment': instance.comment,
      'mapper': instance.mapper,
      'ascent': instance.ascent,
      'height': instance.height,
    };
