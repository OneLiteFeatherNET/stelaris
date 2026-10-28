import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/expression/expression_detail_page.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The [SelectedExpressionState] is a factory class that creates a view model for the currently selected expression.
/// It extends [VmFactory] and is shared by the tabs of the expression detail page.
class SelectedExpressionState
    extends VmFactory<AppState, ExpressionDetailPage, SelectedExpressionView> {
  SelectedExpressionState();

  @override
  SelectedExpressionView fromStore() => SelectedExpressionView(
    selected: state.selectedExpression!,
    projectId: state.selectedExpression?.projectId ?? state.selectedProject?.id,
  );
}

/// The [SelectedExpressionView] is a view model that represents the currently selected expression.
/// It extends [Vm] and provides the expression, which may hold unsaved edits, and the project it runs in.
class SelectedExpressionView extends Vm {
  SelectedExpressionView({required this.selected, required this.projectId})
    : super(equals: [selected, projectId]);

  final ExpressionModel selected;

  /// The project the expression is evaluated in, null when none is known.
  final String? projectId;
}
