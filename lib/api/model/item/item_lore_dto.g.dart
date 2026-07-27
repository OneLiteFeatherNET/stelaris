// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_lore_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemLoreDto _$ItemLoreDtoFromJson(Map<String, dynamic> json) => _ItemLoreDto(
  text: json['text'] as String,
  id: json['id'] as String?,
  orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ItemLoreDtoToJson(_ItemLoreDto instance) =>
    <String, dynamic>{
      'text': instance.text,
      'id': instance.id,
      'orderIndex': instance.orderIndex,
    };
