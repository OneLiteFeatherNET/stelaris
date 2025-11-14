// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_enchantment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemEnchantmentDto _$ItemEnchantmentDtoFromJson(Map<String, dynamic> json) =>
    _ItemEnchantmentDto(
      id: json['id'] as String,
      name: json['name'] as String,
      level: (json['level'] as num).toInt(),
    );

Map<String, dynamic> _$ItemEnchantmentDtoToJson(_ItemEnchantmentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'level': instance.level,
    };
