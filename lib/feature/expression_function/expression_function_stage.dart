import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/actions/expression/expression_function_actions.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Puts [function] into the store and marks the function unsaved. The
/// header's save sends it to the backend.
void stageExpressionFunction(
  BuildContext context,
  ExpressionFunctionModel function,
) {
  context
    ..dispatch(UpdateExpressionFunctionAction(function))
    ..dispatch(MarkUnsavedChangesAction(NavigationEntry.function));
}

/// The backend's messages for [field] in [problem]: the field itself, or one
/// of its parts such as `parameters[0].name`. Empty when there are none.
List<String> violationsFor(ProblemDetail? problem, String field) {
  if (problem == null) return const [];
  return [
    for (final error in problem.errors)
      if (error.field == field ||
          error.field.startsWith('$field.') ||
          error.field.startsWith('$field['))
        error.message,
  ];
}
