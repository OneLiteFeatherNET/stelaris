// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_lore_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemLoreModel _$ItemLoreModelFromJson(Map<String, dynamic> json) =>
    _ItemLoreModel(
      id: json['id'] as String,
      enchantments: Map<String, int>.from(json['enchantments'] as Map),
    );

Map<String, dynamic> _$ItemLoreModelToJson(_ItemLoreModel instance) =>
    <String, dynamic>{'id': instance.id, 'enchantments': instance.enchantments};
