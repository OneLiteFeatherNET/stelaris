// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_enchantment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemEnchantmentModel _$ItemEnchantmentModelFromJson(
  Map<String, dynamic> json,
) => _ItemEnchantmentModel(
  id: json['id'] as String,
  enchantments: Map<String, int>.from(json['enchantments'] as Map),
);

Map<String, dynamic> _$ItemEnchantmentModelToJson(
  _ItemEnchantmentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'enchantments': instance.enchantments,
};
