// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_enchantment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemEnchantmentDto _$ItemEnchantmentDtoFromJson(Map<String, dynamic> json) =>
    _ItemEnchantmentDto(
      name: json['name'] as String,
      level: (json['level'] as num).toInt(),
      unsafe: json['unsafe'] as bool? ?? false,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$ItemEnchantmentDtoToJson(_ItemEnchantmentDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'level': instance.level,
      'unsafe': instance.unsafe,
      'id': instance.id,
    };
