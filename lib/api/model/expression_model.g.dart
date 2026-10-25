// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expression_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpressionVariable _$ExpressionVariableFromJson(Map<String, dynamic> json) =>
    _ExpressionVariable(
      name: json['name'] as String,
      type:
          $enumDecodeNullable(_$ExpressionVariableTypeEnumMap, json['type']) ??
          ExpressionVariableType.NUMBER,
      testValue: json['testValue'] as String?,
    );

Map<String, dynamic> _$ExpressionVariableToJson(_ExpressionVariable instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$ExpressionVariableTypeEnumMap[instance.type]!,
      'testValue': instance.testValue,
    };

const _$ExpressionVariableTypeEnumMap = {
  ExpressionVariableType.NUMBER: 'NUMBER',
  ExpressionVariableType.BOOLEAN: 'BOOLEAN',
  ExpressionVariableType.STRING: 'STRING',
};

_ExpressionResult _$ExpressionResultFromJson(Map<String, dynamic> json) =>
    _ExpressionResult(
      value: json['value'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$ExpressionResultToJson(_ExpressionResult instance) =>
    <String, dynamic>{'value': instance.value, 'type': instance.type};

_ExpressionModel _$ExpressionModelFromJson(Map<String, dynamic> json) =>
    _ExpressionModel(
      uiName: json['uiName'] as String,
      expression: json['expression'] as String? ?? '',
      id: json['id'] as String?,
      comment: json['comment'] as String?,
      variables:
          (json['variables'] as List<dynamic>?)
              ?.map(
                (e) => ExpressionVariable.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      projectId: json['projectId'] as String?,
      creationDate: json['creationDate'] == null
          ? null
          : DateTime.parse(json['creationDate'] as String),
      modificationDate: json['modificationDate'] == null
          ? null
          : DateTime.parse(json['modificationDate'] as String),
    );

Map<String, dynamic> _$ExpressionModelToJson(_ExpressionModel instance) =>
    <String, dynamic>{
      'uiName': instance.uiName,
      'expression': instance.expression,
      'id': instance.id,
      'comment': instance.comment,
      'variables': _variablesToJson(instance.variables),
      'projectId': instance.projectId,
      'creationDate': instance.creationDate?.toIso8601String(),
      'modificationDate': instance.modificationDate?.toIso8601String(),
    };
