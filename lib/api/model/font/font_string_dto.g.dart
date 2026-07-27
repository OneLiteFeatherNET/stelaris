// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_string_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FontStringDto _$FontStringDtoFromJson(Map<String, dynamic> json) =>
    _FontStringDto(
      line: json['line'] as String,
      id: json['id'] as String?,
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$FontStringDtoToJson(_FontStringDto instance) =>
    <String, dynamic>{
      'line': instance.line,
      'id': instance.id,
      'orderIndex': instance.orderIndex,
    };
