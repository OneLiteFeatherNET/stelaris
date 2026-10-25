import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';

/// Puts [expression] into the store and marks the expression unsaved. The
/// header's save sends it to the backend.
void stageExpression(BuildContext context, ExpressionModel expression) {
  context
    ..dispatch(UpdateExpressionAction(expression))
    ..dispatch(MarkUnsavedChangesAction(NavigationEntry.expression));
}
