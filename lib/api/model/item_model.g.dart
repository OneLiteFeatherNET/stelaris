// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemModel _$ItemModelFromJson(Map<String, dynamic> json) => _ItemModel(
  uiName: json['uiName'] as String,
  id: json['id'] as String?,
  variableName: json['variableName'] as String?,
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
      'uiName': instance.uiName,
      'id': instance.id,
      'variableName': instance.variableName,
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
