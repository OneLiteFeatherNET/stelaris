import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_models/stelaris_models.dart';

part 'expression_model.freezed.dart';

part 'expression_model.g.dart';

/// The type of a variable an expression reads.
///
/// The JSON values are the enum names, as the backend expects them. The
/// upper-case names are the wire format, so the lint about them is off here.
// ignore: constant_identifier_names
enum ExpressionVariableType { NUMBER, BOOLEAN, STRING }

/// A named input of an [ExpressionModel].
///
/// [testValue] is the value the expression is evaluated with on the test tab,
/// as text. It stays null when none was entered.
@freezed
abstract class ExpressionVariable with _$ExpressionVariable {
  const ExpressionVariable._();

  const factory ExpressionVariable({
    required String name,
    @Default(ExpressionVariableType.NUMBER) ExpressionVariableType type,
    String? testValue,
  }) = _ExpressionVariable;

  factory ExpressionVariable.fromJson(Map<String, dynamic> json) =>
      _$ExpressionVariableFromJson(json);
}

/// The result of evaluating an expression: its value and the type the
/// backend gave it, both as text.
@freezed
abstract class ExpressionResult with _$ExpressionResult {
  const factory ExpressionResult({
    required String value,
    required String type,
  }) = _ExpressionResult;

  factory ExpressionResult.fromJson(Map<String, dynamic> json) =>
      _$ExpressionResultFromJson(json);
}

/// The variables as JSON objects. Freezed would otherwise write the Dart
/// instances into the map, which is not encodable.
List<Map<String, dynamic>> _variablesToJson(
  List<ExpressionVariable> variables,
) => [for (final variable in variables) variable.toJson()];

/// An EvalEx math formula of a project, with the variables it reads.
///
/// Expressions are listed, created and deleted like the other models, and
/// they are project scoped, so [projectId] is set by the backend.
@freezed
abstract class ExpressionModel with _$ExpressionModel, DataModel {
  const ExpressionModel._();

  const factory ExpressionModel({
    required String uiName,
    @Default('') String expression,
    String? id,
    String? comment,
    @JsonKey(toJson: _variablesToJson)
    @Default([])
    List<ExpressionVariable> variables,
    String? projectId,
    DateTime? creationDate,
    DateTime? modificationDate,
  }) = _ExpressionModel;

  factory ExpressionModel.fromJson(Map<String, dynamic> json) =>
      _$ExpressionModelFromJson(json);
}
