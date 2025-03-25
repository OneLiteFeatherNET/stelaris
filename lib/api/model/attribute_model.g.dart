// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribute_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttributeModel _$AttributeModelFromJson(Map<String, dynamic> json) =>
    _AttributeModel(
      id: json['id'] as String?,
      modelName: json['modelName'] as String?,
      name: json['name'] as String?,
      defaultValue: (json['defaultValue'] as num?)?.toDouble() ?? 0.0,
      maximumValue: (json['maximumValue'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$AttributeModelToJson(_AttributeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelName': instance.modelName,
      'name': instance.name,
      'defaultValue': instance.defaultValue,
      'maximumValue': instance.maximumValue,
    };
