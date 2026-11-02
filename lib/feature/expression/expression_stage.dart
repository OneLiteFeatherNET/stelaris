import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Puts [expression] into the store, which marks the expression unsaved. The
/// header's save sends it to the backend.
void stageExpression(BuildContext context, ExpressionModel expression) {
  context.dispatch(UpdateExpressionAction(expression));
}
