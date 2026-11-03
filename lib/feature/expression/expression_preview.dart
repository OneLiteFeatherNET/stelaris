import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression/selected_expression_state.dart';
import 'package:stelaris/feature/expression/expression_math_view.dart';
import 'package:stelaris/feature/expression/expression_preview_panel.dart';
import 'package:stelaris/feature/expression/expression_preview_scope.dart';
import 'package:stelaris/feature/expression/expression_tex.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The live result of the selected expression, as the formula is typed: an
/// [ExpressionPreviewPanel] with the formula when [showFormula], and the
/// variables with their test values. Shown beside the General tab on a wide
/// screen, and as a bottom sheet on a narrow one.
///
/// The values start as the variables' test values, which the Variables tab
/// edits, and can be changed in the preview to try others. Those changes are
/// kept in the [ExpressionPreviewScope] above, or in the preview itself
/// without one, until they are reset.
class ExpressionPreview extends StatelessWidget {
  const ExpressionPreview({
    this.debounce = expressionPreviewDebounce,
    this.showFormula = true,
    super.key,
  });

  /// Whether the formula is shown too. Off beside a page that shows it
  /// already.
  final bool showFormula;

  /// The pause after a change before the backend is asked, see
  /// [expressionPreviewDebounce].
  final Duration debounce;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedExpressionView>(
      vm: () => SelectedExpressionState(),
      builder: (context, vm) => StoreConnector<AppState, ExpressionCatalog?>(
        converter: (store) => store.state.expressionCatalog,
        builder: (context, catalog) {
          final variables = vm.selected.variables;
          final expression = vm.selected.expression;
          return ExpressionPreviewValues(
            variables: variables,
            builder: (context, overrides, onOverridesChanged) =>
                ExpressionPreviewPanel(
                  request: _ExpressionRequest(
                    projectId: vm.projectId,
                    expression: expression,
                    variables: withPreviewValues(variables, overrides),
                  ),
                  variables: variables,
                  overrides: overrides,
                  onOverridesChanged: onOverridesChanged,
                  debounce: debounce,
                  formula: showFormula
                      ? _PreviewFormula(formula: expression, catalog: catalog)
                      : null,
                ),
          );
        },
      ),
    );
  }
}

/// An expression's formula with its variables, as the preview sends it.
@immutable
class _ExpressionRequest extends ExpressionPreviewRequest {
  const _ExpressionRequest({
    required this.projectId,
    required this.expression,
    required this.variables,
  });

  @override
  final String? projectId;
  final String expression;
  @override
  final List<ExpressionVariable> variables;

  @override
  String get formula => expression;

  @override
  Future<ExpressionResult> evaluate(String projectId) =>
      ApiService().expressionApi.evaluate(projectId, expression, variables);

  @override
  bool operator ==(Object other) =>
      other is _ExpressionRequest &&
      other.projectId == projectId &&
      other.expression == expression &&
      listEquals(other.variables, variables);

  @override
  int get hashCode =>
      Object.hash(projectId, expression, Object.hashAll(variables));
}

/// The formula typeset, with the functions named by the [catalog], or a hint
/// while it is empty.
class _PreviewFormula extends StatefulWidget {
  const _PreviewFormula({required this.formula, required this.catalog});

  final String formula;

  /// Names the functions the formula is typeset with. Not part of the request:
  /// the backend's answer does not depend on it.
  final ExpressionCatalog? catalog;

  @override
  State<_PreviewFormula> createState() => _PreviewFormulaState();
}

class _PreviewFormulaState extends State<_PreviewFormula> {
  /// The formula last typeset by [_tex], with the catalog it was named by.
  ({String formula, ExpressionCatalog? catalog, String? tex})? _texMemo;

  /// The LaTeX of [formula], null when it does not convert. The last one is
  /// kept while the formula and the catalog stay the same, since the preview
  /// rebuilds whenever a value is typed in.
  String? _tex(String formula) {
    final catalog = widget.catalog;
    final memo = _texMemo;
    if (memo != null &&
        memo.formula == formula &&
        identical(memo.catalog, catalog)) {
      return memo.tex;
    }
    final tex = expressionToTex(
      formula,
      functionNames: catalogFunctionNames(catalog),
    );
    _texMemo = (formula: formula, catalog: catalog, tex: tex);
    return tex;
  }

  @override
  Widget build(BuildContext context) {
    final formula = widget.formula;
    if (formula.trim().isEmpty) {
      return Text(
        context.l10n.expression_preview_empty_hint,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return ExpressionMathView(
      formula: formula,
      tex: _tex(formula),
      fontSize: 22,
    );
  }
}
