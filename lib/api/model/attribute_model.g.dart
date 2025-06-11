// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribute_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttributeModel _$AttributeModelFromJson(Map<String, dynamic> json) =>
    _AttributeModel(
      uiName: json['uiName'] as String,
      id: json['id'] as String?,
      variableName: json['variableName'] as String?,
      defaultValue: (json['defaultValue'] as num?)?.toDouble() ?? 0.0,
      maximumValue: (json['maximumValue'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$AttributeModelToJson(_AttributeModel instance) =>
    <String, dynamic>{
      'uiName': instance.uiName,
      'id': instance.id,
      'variableName': instance.variableName,
      'defaultValue': instance.defaultValue,
      'maximumValue': instance.maximumValue,
    };
