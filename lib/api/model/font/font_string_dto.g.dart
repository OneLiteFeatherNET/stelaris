// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_string_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FontStringDto _$FontStringDtoFromJson(Map<String, dynamic> json) =>
    _FontStringDto(
      id: json['id'] as String,
      line: json['line'] as String,
      orderIndex: (json['orderIndex'] as num).toInt(),
    );

Map<String, dynamic> _$FontStringDtoToJson(_FontStringDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'line': instance.line,
      'orderIndex': instance.orderIndex,
    };
