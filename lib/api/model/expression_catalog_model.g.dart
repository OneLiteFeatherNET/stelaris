// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expression_catalog_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpressionCatalog _$ExpressionCatalogFromJson(Map<String, dynamic> json) =>
    _ExpressionCatalog(
      evalexVersion: json['evalexVersion'] as String? ?? '',
      functions:
          (json['functions'] as List<dynamic>?)
              ?.map((e) => CatalogFunction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      operators:
          (json['operators'] as List<dynamic>?)
              ?.map((e) => CatalogOperator.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      constants:
          (json['constants'] as List<dynamic>?)
              ?.map((e) => CatalogConstant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ExpressionCatalogToJson(_ExpressionCatalog instance) =>
    <String, dynamic>{
      'evalexVersion': instance.evalexVersion,
      'functions': instance.functions,
      'operators': instance.operators,
      'constants': instance.constants,
    };

_CatalogFunction _$CatalogFunctionFromJson(Map<String, dynamic> json) =>
    _CatalogFunction(
      name: json['name'] as String,
      category:
          $enumDecodeNullable(
            _$CatalogFunctionCategoryEnumMap,
            json['category'],
            unknownValue: CatalogFunctionCategory.other,
          ) ??
          CatalogFunctionCategory.other,
      parameters:
          (json['parameters'] as List<dynamic>?)
              ?.map((e) => CatalogParameter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CatalogFunctionToJson(_CatalogFunction instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': _$CatalogFunctionCategoryEnumMap[instance.category]!,
      'parameters': instance.parameters,
    };

const _$CatalogFunctionCategoryEnumMap = {
  CatalogFunctionCategory.basic: 'BASIC',
  CatalogFunctionCategory.string: 'STRING',
  CatalogFunctionCategory.dateTime: 'DATE_TIME',
  CatalogFunctionCategory.trigonometric: 'TRIGONOMETRIC',
  CatalogFunctionCategory.other: 'OTHER',
};

_CatalogParameter _$CatalogParameterFromJson(Map<String, dynamic> json) =>
    _CatalogParameter(
      name: json['name'] as String,
      varArg: json['varArg'] as bool? ?? false,
      lazy: json['lazy'] as bool? ?? false,
      nonZero: json['nonZero'] as bool? ?? false,
      nonNegative: json['nonNegative'] as bool? ?? false,
    );

Map<String, dynamic> _$CatalogParameterToJson(_CatalogParameter instance) =>
    <String, dynamic>{
      'name': instance.name,
      'varArg': instance.varArg,
      'lazy': instance.lazy,
      'nonZero': instance.nonZero,
      'nonNegative': instance.nonNegative,
    };

_CatalogOperator _$CatalogOperatorFromJson(Map<String, dynamic> json) =>
    _CatalogOperator(
      symbol: json['symbol'] as String,
      kind:
          $enumDecodeNullable(
            _$CatalogOperatorKindEnumMap,
            json['kind'],
            unknownValue: CatalogOperatorKind.other,
          ) ??
          CatalogOperatorKind.other,
      precedence: (json['precedence'] as num?)?.toInt() ?? 0,
      leftAssociative: json['leftAssociative'] as bool? ?? true,
    );

Map<String, dynamic> _$CatalogOperatorToJson(_CatalogOperator instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'kind': _$CatalogOperatorKindEnumMap[instance.kind]!,
      'precedence': instance.precedence,
      'leftAssociative': instance.leftAssociative,
    };

const _$CatalogOperatorKindEnumMap = {
  CatalogOperatorKind.prefix: 'PREFIX',
  CatalogOperatorKind.infix: 'INFIX',
  CatalogOperatorKind.postfix: 'POSTFIX',
  CatalogOperatorKind.other: 'OTHER',
};

_CatalogConstant _$CatalogConstantFromJson(Map<String, dynamic> json) =>
    _CatalogConstant(
      name: json['name'] as String,
      type:
          $enumDecodeNullable(
            _$CatalogConstantTypeEnumMap,
            json['type'],
            unknownValue: CatalogConstantType.other,
          ) ??
          CatalogConstantType.other,
      value: json['value'] as String? ?? '',
    );

Map<String, dynamic> _$CatalogConstantToJson(_CatalogConstant instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$CatalogConstantTypeEnumMap[instance.type]!,
      'value': instance.value,
    };

const _$CatalogConstantTypeEnumMap = {
  CatalogConstantType.number: 'NUMBER',
  CatalogConstantType.boolean: 'BOOLEAN',
  CatalogConstantType.string: 'STRING',
  CatalogConstantType.other: 'OTHER',
};
