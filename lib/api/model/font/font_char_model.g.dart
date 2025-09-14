// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_char_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FontCharModel _$FontCharModelFromJson(Map<String, dynamic> json) =>
    _FontCharModel(
      id: json['id'] as String,
      chars: (json['chars'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$FontCharModelToJson(_FontCharModel instance) =>
    <String, dynamic>{'id': instance.id, 'chars': instance.chars};
