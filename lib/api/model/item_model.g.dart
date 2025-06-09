// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemModel _$ItemModelFromJson(Map<String, dynamic> json) => _ItemModel(
  id: json['id'] as String?,
  modelName: json['modelName'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  displayName: json['displayName'] as String?,
  group:
      $enumDecodeNullable(_$ItemGroupEnumMap, json['group']) ?? ItemGroup.misc,
  material: json['material'] as String?,
  customModelId: (json['customModelId'] as num?)?.toInt(),
  amount: (json['amount'] as num?)?.toInt() ?? 1,
  enchantments: (json['enchantments'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  flags: (json['flags'] as List<dynamic>?)?.map((e) => e as String).toSet(),
  lore: (json['lore'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$ItemModelToJson(_ItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelName': instance.modelName,
      'name': instance.name,
      'description': instance.description,
      'displayName': instance.displayName,
      'group': _$ItemGroupEnumMap[instance.group]!,
      'material': instance.material,
      'customModelId': instance.customModelId,
      'amount': instance.amount,
      'enchantments': instance.enchantments,
      'flags': instance.flags?.toList(),
      'lore': instance.lore,
    };

const _$ItemGroupEnumMap = {
  ItemGroup.misc: 'misc',
  ItemGroup.armor: 'armor',
  ItemGroup.meeleWeapon: 'meeleWeapon',
  ItemGroup.rangedWeapon: 'rangedWeapon',
  ItemGroup.tools: 'tools',
};
