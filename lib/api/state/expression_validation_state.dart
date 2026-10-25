import 'package:flutter/foundation.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/model/expression_validation_model.dart';

/// The backend's answer for the formula [expression] and the declared
/// [variables] (their names) it was asked about. Transient, like the other
/// editor state: it is never persisted.
@immutable
class ExpressionValidationState {
  const ExpressionValidationState({
    required this.expression,
    required this.variables,
    required this.validation,
  });

  final String expression;
  final List<String> variables;
  final ExpressionValidation validation;

  /// The validation of [model] when it still belongs to the text and the
  /// declared variables of [model]; null when they changed since it was asked.
  static ExpressionValidation? forModel(
    ExpressionValidationState? state,
    ExpressionModel model,
  ) {
    if (state == null || !state.belongsTo(model)) return null;
    return state.validation;
  }

  /// Whether the answer was asked for the text and variables of [model].
  bool belongsTo(ExpressionModel model) =>
      expression == model.expression &&
      listEquals(variables, variableNames(model));

  @override
  bool operator ==(Object other) =>
      other is ExpressionValidationState &&
      other.expression == expression &&
      listEquals(other.variables, variables) &&
      other.validation == validation;

  @override
  int get hashCode =>
      Object.hash(expression, Object.hashAll(variables), validation);
}

/// The declared variable names of [model], in declaration order.
List<String> variableNames(ExpressionModel model) => [
  for (final variable in model.variables) variable.name,
];
