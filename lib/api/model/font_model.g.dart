// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FontModel _$FontModelFromJson(Map<String, dynamic> json) => _FontModel(
  uiName: json['uiName'] as String,
  id: json['id'] as String?,
  variableName: json['variableName'] as String?,
  provider: json['provider'] as String?,
  texturePath: json['texturePath'] as String?,
  comment: json['comment'] as String?,
  mapper: json['mapper'] as String? ?? 'font',
  ascent: (json['ascent'] as num?)?.toInt() ?? 0,
  height: (json['height'] as num?)?.toInt() ?? 0,
  chars: json['chars'] == null
      ? FontModel._defaultFiles
      : PaginatedResult<FontStringDTO>.fromJson(
          json['chars'] as Map<String, dynamic>,
          (value) => FontStringDTO.fromJson(value as Map<String, dynamic>),
        ),
  isLoadingChars: json['isLoadingChars'] as bool? ?? false,
);

Map<String, dynamic> _$FontModelToJson(_FontModel instance) =>
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
      'chars': instance.chars.toJson((value) => value),
    };
