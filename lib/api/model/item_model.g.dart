// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemModel _$ItemModelFromJson(Map<String, dynamic> json) => _ItemModel(
  uiName: json['uiName'] as String,
  id: json['id'] as String?,
  variableName: json['variableName'] as String?,
  comment: json['comment'] as String?,
  displayName: json['displayName'] as String?,
  groupName:
      $enumDecodeNullable(_$EnchantmentGroupEnumMap, json['groupName']) ??
      EnchantmentGroup.meta,
  material: json['material'] as String?,
  customModelData: (json['customModelData'] as num?)?.toInt(),
  amount: (json['amount'] as num?)?.toInt() ?? 1,
  enchantments: json['enchantments'] == null
      ? ItemModel.defaultEnchantments
      : PaginatedResult<ItemEnchantmentDto>.fromJson(
          json['enchantments'] as Map<String, dynamic>,
          (value) => ItemEnchantmentDto.fromJson(value as Map<String, dynamic>),
        ),
  lore: json['lore'] == null
      ? ItemModel._defaultLore
      : PaginatedResult<ItemLoreDto>.fromJson(
          json['lore'] as Map<String, dynamic>,
          (value) => ItemLoreDto.fromJson(value as Map<String, dynamic>),
        ),
  flags: json['flags'] == null
      ? ItemModel._defaultFlags
      : PaginatedResult<ItemFlagDto>.fromJson(
          json['flags'] as Map<String, dynamic>,
          (value) => ItemFlagDto.fromJson(value as Map<String, dynamic>),
        ),
  isLoadingMoreEnchantments:
      json['isLoadingMoreEnchantments'] as bool? ?? false,
  isLoadingMoreLoreLines: json['isLoadingMoreLoreLines'] as bool? ?? false,
);

Map<String, dynamic> _$ItemModelToJson(_ItemModel instance) =>
    <String, dynamic>{
      'uiName': instance.uiName,
      'id': instance.id,
      'variableName': instance.variableName,
      'comment': instance.comment,
      'displayName': instance.displayName,
      'groupName': _$EnchantmentGroupEnumMap[instance.groupName]!,
      'material': instance.material,
      'customModelData': instance.customModelData,
      'amount': instance.amount,
      'enchantments': instance.enchantments.toJson((value) => value),
      'lore': instance.lore.toJson((value) => value),
      'flags': instance.flags.toJson((value) => value),
    };

const _$EnchantmentGroupEnumMap = {
  EnchantmentGroup.armor: 'armor',
  EnchantmentGroup.weapon: 'weapon',
  EnchantmentGroup.meta: 'meta',
  EnchantmentGroup.tools: 'tools',
};
