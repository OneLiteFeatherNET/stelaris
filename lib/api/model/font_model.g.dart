// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FontModelImpl _$$FontModelImplFromJson(Map<String, dynamic> json) =>
    _$FontModelImpl(
      id: json['id'] as String?,
      modelName: json['modelName'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      type: $enumDecodeNullable(_$FontTypeEnumMap, json['type']) ??
          FontType.bitmap,
      chars:
          (json['chars'] as List<dynamic>?)?.map((e) => e as String).toList(),
      ascent: (json['ascent'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      shift: (json['shift'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$FontModelImplToJson(_$FontModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelName': instance.modelName,
      'name': instance.name,
      'description': instance.description,
      'type': _$FontTypeEnumMap[instance.type]!,
      'chars': instance.chars,
      'ascent': instance.ascent,
      'height': instance.height,
      'shift': instance.shift,
    };

const _$FontTypeEnumMap = {
  FontType.bitmap: 'bitmap',
  FontType.legacyUnicode: 'legacyUnicode',
  FontType.ttf: 'ttf',
};
