// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_lore_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemLoreModel _$ItemLoreModelFromJson(Map<String, dynamic> json) =>
    _ItemLoreModel(
      id: json['id'] as String,
      lore: (json['lore'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ItemLoreModelToJson(_ItemLoreModel instance) =>
    <String, dynamic>{'id': instance.id, 'lore': instance.lore};
