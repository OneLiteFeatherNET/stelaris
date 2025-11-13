// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_lore_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemLoreDto _$ItemLoreDtoFromJson(Map<String, dynamic> json) => _ItemLoreDto(
  id: json['id'] as String,
  text: json['text'] as String,
  orderIndex: (json['orderIndex'] as num).toInt(),
);

Map<String, dynamic> _$ItemLoreDtoToJson(_ItemLoreDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'orderIndex': instance.orderIndex,
    };
