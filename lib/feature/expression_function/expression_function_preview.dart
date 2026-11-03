import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression_function/selected_expression_function_state.dart';
import 'package:stelaris/feature/expression/expression_preview_panel.dart';
import 'package:stelaris/feature/expression/expression_preview_scope.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The live result of the selected function as it is now, possibly unsaved,
/// called with its parameters' test values: an [ExpressionPreviewPanel] beside
/// the General tab on a wide screen, and a bottom sheet on a narrow one. The
/// General tab shows the body, so the preview does not.
///
/// The values start as the parameters' test values, which the Parameters tab
/// edits, and can be changed here to try others. Those changes are kept in
/// the [ExpressionPreviewScope] above until they are reset, and never stored.
/// An interface is evaluated through its test stub only.
class ExpressionFunctionPreview extends StatelessWidget {
  const ExpressionFunctionPreview({
    this.debounce = expressionPreviewDebounce,
    super.key,
  });

  /// The pause after a change before the backend is asked, see
  /// [expressionPreviewDebounce].
  final Duration debounce;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedExpressionFunctionView>(
      vm: () => SelectedExpressionFunctionState(),
      builder: (context, vm) {
        final l10n = context.l10n;
        final function = vm.selected;
        final parameters = function.parameters;
        return ExpressionPreviewValues(
          variables: parameters,
          builder: (context, overrides, onOverridesChanged) =>
              ExpressionPreviewPanel(
                request: _FunctionRequest(
                  projectId: vm.projectId,
                  function: function.copyWith(
                    parameters: withPreviewValues(parameters, overrides),
                  ),
                ),
                variables: parameters,
                overrides: overrides,
                onOverridesChanged: onOverridesChanged,
                debounce: debounce,
                variablesTitle: l10n.expression_function_preview_parameters,
                noVariablesHint: l10n.expression_function_preview_no_parameters,
                emptyHint: function.kind == ExpressionFunctionKind.interface
                    ? l10n.expression_function_preview_interface_hint
                    : l10n.expression_function_preview_empty_hint,
              ),
        );
      },
    );
  }
}

/// The function with the values to try as its parameters' test values, as
/// the preview sends it.
@immutable
class _FunctionRequest extends ExpressionPreviewRequest {
  const _FunctionRequest({required this.projectId, required this.function});

  @override
  final String? projectId;
  final ExpressionFunctionModel function;

  @override
  String get formula => function.body ?? '';

  @override
  List<ExpressionVariable> get variables => function.parameters;

  @override
  Future<ExpressionResult> evaluate(String projectId) =>
      ApiService().expressionFunctionApi.evaluate(projectId, function);

  @override
  bool operator ==(Object other) =>
      other is _FunctionRequest &&
      other.projectId == projectId &&
      other.function == function;

  @override
  int get hashCode => Object.hash(projectId, function);
}
