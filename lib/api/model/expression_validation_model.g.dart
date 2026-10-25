// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expression_validation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpressionValidationError _$ExpressionValidationErrorFromJson(
  Map<String, dynamic> json,
) => _ExpressionValidationError(
  message: json['message'] as String,
  start: (json['start'] as num).toInt(),
  end: (json['end'] as num).toInt(),
);

Map<String, dynamic> _$ExpressionValidationErrorToJson(
  _ExpressionValidationError instance,
) => <String, dynamic>{
  'message': instance.message,
  'start': instance.start,
  'end': instance.end,
};

_ExpressionValidation _$ExpressionValidationFromJson(
  Map<String, dynamic> json,
) => _ExpressionValidation(
  valid: json['valid'] as bool,
  errors:
      (json['errors'] as List<dynamic>?)
          ?.map(
            (e) =>
                ExpressionValidationError.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  usedVariables:
      (json['usedVariables'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  undefinedVariables:
      (json['undefinedVariables'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  unusedVariables:
      (json['unusedVariables'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$ExpressionValidationToJson(
  _ExpressionValidation instance,
) => <String, dynamic>{
  'valid': instance.valid,
  'errors': instance.errors,
  'usedVariables': instance.usedVariables,
  'undefinedVariables': instance.undefinedVariables,
  'unusedVariables': instance.unusedVariables,
};
