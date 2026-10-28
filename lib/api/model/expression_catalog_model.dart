import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/api/model/expression_function_model.dart';
import 'package:stelaris/api/model/expression_model.dart';

part 'expression_catalog_model.freezed.dart';

part 'expression_catalog_model.g.dart';

/// Reads a wire name as one of [values], or null when it names none. The
/// catalog is read tolerantly, so a value this app does not know must not
/// fail the whole catalog.
T? _enumOrNull<T extends Enum>(List<T> values, Object? name) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

ExpressionFunctionKind? _functionKindFromJson(Object? name) =>
    _enumOrNull(ExpressionFunctionKind.values, name);

ExpressionFunctionReturnType? _functionReturnTypeFromJson(Object? name) =>
    _enumOrNull(ExpressionFunctionReturnType.values, name);

ExpressionVariableType? _parameterTypeFromJson(Object? name) =>
    _enumOrNull(ExpressionVariableType.values, name);

/// The EvalEx functions, operators and constants the backend supports, and the
/// functions the project defines. The project's functions differ per project,
/// so the catalog is loaded per project and only read by the formula editor.
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

  /// A function the project defines, see [ExpressionFunctionModel].
  @JsonValue('PROJECT')
  project,
}

/// An EvalEx function, or a function the project defines, with the parameters
/// it takes, in call order. A project function also has a [description], its
/// [kind] and its [returnType].
@freezed
abstract class CatalogFunction with _$CatalogFunction {
  const factory CatalogFunction({
    required String name,
    @JsonKey(unknownEnumValue: CatalogFunctionCategory.other)
    @Default(CatalogFunctionCategory.other)
    CatalogFunctionCategory category,
    @Default([]) List<CatalogParameter> parameters,
    String? description,
    @JsonKey(fromJson: _functionKindFromJson) ExpressionFunctionKind? kind,
    @JsonKey(fromJson: _functionReturnTypeFromJson)
    ExpressionFunctionReturnType? returnType,
  }) = _CatalogFunction;

  factory CatalogFunction.fromJson(Map<String, dynamic> json) =>
      _$CatalogFunctionFromJson(json);
}

/// A parameter of a [CatalogFunction]. A vararg parameter takes all the
/// arguments from its position on, so it is always the last one. A project
/// function's parameter has a [type]; EvalEx parameters have none.
@freezed
abstract class CatalogParameter with _$CatalogParameter {
  const factory CatalogParameter({
    required String name,
    @JsonKey(fromJson: _parameterTypeFromJson) ExpressionVariableType? type,
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
