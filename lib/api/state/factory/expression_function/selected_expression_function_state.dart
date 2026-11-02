import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/expression_function/expression_function_detail_page.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The view of the selected function that the detail page's tabs share: the
/// function, which may hold unsaved edits, the project it runs in and the
/// rejection of its last save, if any.
class SelectedExpressionFunctionState
    extends
        VmFactory<
          AppState,
          ExpressionFunctionDetailPage,
          SelectedExpressionFunctionView
        > {
  SelectedExpressionFunctionState();

  @override
  SelectedExpressionFunctionView fromStore() => SelectedExpressionFunctionView(
    selected: state.selectedExpressionFunction!,
    projectId:
        state.selectedExpressionFunction?.projectId ??
        state.selectedProject?.id,
    problem: state.expressionFunctionProblem,
  );
}

class SelectedExpressionFunctionView extends Vm {
  SelectedExpressionFunctionView({
    required this.selected,
    required this.projectId,
    required this.problem,
  }) : super(equals: [selected, projectId, problem]);

  final ExpressionFunctionModel selected;

  /// The project the function is evaluated in, null when none is known.
  final String? projectId;

  /// The backend's rejection of the last save, null when there is none.
  final ProblemDetail? problem;
}
