// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_flag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemFlagModel _$ItemFlagModelFromJson(Map<String, dynamic> json) =>
    _ItemFlagModel(
      id: json['id'] as String,
      flags: (json['flags'] as List<dynamic>).map((e) => e as String).toSet(),
    );

Map<String, dynamic> _$ItemFlagModelToJson(_ItemFlagModel instance) =>
    <String, dynamic>{'id': instance.id, 'flags': instance.flags.toList()};
