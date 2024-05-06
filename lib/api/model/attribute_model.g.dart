// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribute_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttributeModelImpl _$$AttributeModelImplFromJson(Map<String, dynamic> json) =>
    _$AttributeModelImpl(
      id: json['id'] as String?,
      modelName: json['modelName'] as String?,
      name: json['name'] as String?,
      defaultValue: (json['defaultValue'] as num?)?.toDouble() ?? 0.0,
      maximumValue: (json['maximumValue'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$AttributeModelImplToJson(
        _$AttributeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelName': instance.modelName,
      'name': instance.name,
      'defaultValue': instance.defaultValue,
      'maximumValue': instance.maximumValue,
    };
