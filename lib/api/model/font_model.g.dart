// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FontModel _$FontModelFromJson(Map<String, dynamic> json) => _FontModel(
  id: json['id'] as String?,
  uiName: json['uiName'] as String,
  variableName: json['variableName'] as String?,
  provider: json['provider'] as String?,
  texturePath: json['texturePath'] as String?,
  comment: json['comment'] as String?,
  mapper: json['mapper'] as String? ?? 'font',
  ascent: (json['ascent'] as num?)?.toInt() ?? 0,
  height: (json['height'] as num?)?.toInt() ?? 0,
  chars:
      (json['chars'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$FontModelToJson(_FontModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uiName': instance.uiName,
      'variableName': instance.variableName,
      'provider': instance.provider,
      'texturePath': instance.texturePath,
      'comment': instance.comment,
      'mapper': instance.mapper,
      'ascent': instance.ascent,
      'height': instance.height,
      'chars': instance.chars,
    };
