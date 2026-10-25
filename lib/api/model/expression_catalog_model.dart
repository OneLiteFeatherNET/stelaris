import 'package:freezed_annotation/freezed_annotation.dart';

part 'expression_catalog_model.freezed.dart';

part 'expression_catalog_model.g.dart';

/// The EvalEx functions, operators and constants the backend supports. It is
/// the same for every project, so it is loaded once and only read by the
/// formula editor.
@freezed
abstract class ExpressionCatalog with _$ExpressionCatalog {
  const factory ExpressionCatalog({
    @Default('') String evalexVersion,
    @Default([]) List<CatalogFunction> functions,
    @Default([]) List<CatalogOperator> operators,
    @Default([]) List<CatalogConstant> constants,
  }) = _ExpressionCatalog;

  factory ExpressionCatalog.fromJson(Map<String, dynamic> json) =>
      _$ExpressionCatalogFromJson(json);
}

/// The group a function is listed under. Unknown categories read as [other].
enum CatalogFunctionCategory {
  @JsonValue('BASIC')
  basic,
  @JsonValue('STRING')
  string,
  @JsonValue('DATE_TIME')
  dateTime,
  @JsonValue('TRIGONOMETRIC')
  trigonometric,
  @JsonValue('OTHER')
  other,
}

/// An EvalEx function with the parameters it takes, in call order.
@freezed
abstract class CatalogFunction with _$CatalogFunction {
  const factory CatalogFunction({
    required String name,
    @JsonKey(unknownEnumValue: CatalogFunctionCategory.other)
    @Default(CatalogFunctionCategory.other)
    CatalogFunctionCategory category,
    @Default([]) List<CatalogParameter> parameters,
  }) = _CatalogFunction;

  factory CatalogFunction.fromJson(Map<String, dynamic> json) =>
      _$CatalogFunctionFromJson(json);
}

/// A parameter of a [CatalogFunction]. A vararg parameter takes all the
/// arguments from its position on, so it is always the last one.
@freezed
abstract class CatalogParameter with _$CatalogParameter {
  const factory CatalogParameter({
    required String name,
    @Default(false) bool varArg,
    @Default(false) bool lazy,
    @Default(false) bool nonZero,
    @Default(false) bool nonNegative,
  }) = _CatalogParameter;

  factory CatalogParameter.fromJson(Map<String, dynamic> json) =>
      _$CatalogParameterFromJson(json);
}

/// How an operator is written: before its operand, between two, or after it.
enum CatalogOperatorKind {
  @JsonValue('PREFIX')
  prefix,
  @JsonValue('INFIX')
  infix,
  @JsonValue('POSTFIX')
  postfix,
  @JsonValue('OTHER')
  other,
}

/// An EvalEx operator, with the precedence the parser gives it.
@freezed
abstract class CatalogOperator with _$CatalogOperator {
  const factory CatalogOperator({
    required String symbol,
    @JsonKey(unknownEnumValue: CatalogOperatorKind.other)
    @Default(CatalogOperatorKind.other)
    CatalogOperatorKind kind,
    @Default(0) int precedence,
    @Default(true) bool leftAssociative,
  }) = _CatalogOperator;

  factory CatalogOperator.fromJson(Map<String, dynamic> json) =>
      _$CatalogOperatorFromJson(json);
}

/// The type of a [CatalogConstant]'s value. Unknown types read as [other].
enum CatalogConstantType {
  @JsonValue('NUMBER')
  number,
  @JsonValue('BOOLEAN')
  boolean,
  @JsonValue('STRING')
  string,
  @JsonValue('OTHER')
  other,
}

/// A named value of EvalEx, such as `PI`. [value] is the value as text.
@freezed
abstract class CatalogConstant with _$CatalogConstant {
  const factory CatalogConstant({
    required String name,
    @JsonKey(unknownEnumValue: CatalogConstantType.other)
    @Default(CatalogConstantType.other)
    CatalogConstantType type,
    @Default('') String value,
  }) = _CatalogConstant;

  factory CatalogConstant.fromJson(Map<String, dynamic> json) =>
      _$CatalogConstantFromJson(json);
}
