import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/model/expression_validation_model.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/expression_validation_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_card.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/feature/expression/expression_formula_field.dart';
import 'package:stelaris/feature/expression/expression_math_view.dart';
import 'package:stelaris/feature/expression/expression_preview_scope.dart';
import 'package:stelaris/feature/expression/expression_stage.dart';
import 'package:stelaris/feature/expression/expression_tex.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The expression's General tab: its formula, edited in place with variable
/// suggestions. While the formula is typed the backend checks it, and the
/// check is shown under the field. The backend checks the formula on save too,
/// so nothing is parsed here.
class ExpressionGeneralPage extends StatelessWidget {
  const ExpressionGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ExpressionGeneralView>(
      vm: () => _ExpressionGeneralFactory(),
      // The check of the formula as it was when the tab opened: the store may
      // hold none, or one for an older text, e.g. after a tab switch.
      onInitialBuild: (_, store, vm) {
        final check = _validation(vm.projectId, vm.selected);
        if (check != null) store.dispatch(check);
      },
      builder: (context, vm) {
        final expression = vm.selected;
        final l10n = context.l10n;
        final theme = Theme.of(context);
        return ExpressionPreviewBeside(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ExpressionFormulaField(
                key: const ValueKey('expression_formula_field'),
                expression: expression,
                catalog: vm.catalog,
                validation: vm.validation,
                onChanged: (value) =>
                    _stage(context, vm, expression.copyWith(expression: value)),
                onDeclare: (names) => _declare(context, vm, names),
                // The formula and the variables are each a section on a
                // surface of their own.
                sections: (editor, variables) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EditSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          EditSectionHeading(
                            title: l10n.expression_section_formula,
                          ),
                          const SizedBox(height: 8),
                          if (expression.expression.trim().isNotEmpty) ...[
                            Text(
                              l10n.expression_rendered_formula_label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ExpressionMathView(
                              formula: expression.expression,
                              tex: expressionToTex(
                                expression.expression,
                                functionNames: catalogFunctionNames(vm.catalog),
                              ),
                              fontSize: 16,
                            ),
                            const SizedBox(height: 12),
                          ],
                          editor,
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    EditSectionCard(child: variables),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Stages [expression] and asks the backend about it.
  void _stage(
    BuildContext context,
    _ExpressionGeneralView vm,
    ExpressionModel expression,
  ) {
    stageExpression(context, expression);
    final check = _validation(vm.projectId, expression);
    if (check != null) context.dispatch(check);
  }

  /// Declares [names] as numeric variables. A name the expression already
  /// declares, in any case, is left as it is.
  void _declare(
    BuildContext context,
    _ExpressionGeneralView vm,
    List<String> names,
  ) {
    final expression = vm.selected;
    final declared = {
      for (final variable in expression.variables) variable.name.toLowerCase(),
    };
    final added = [
      for (final name in names)
        if (declared.add(name.toLowerCase()))
          ExpressionVariable(name: name, type: ExpressionVariableType.NUMBER),
    ];
    if (added.isEmpty) return;
    _stage(
      context,
      vm,
      expression.copyWith(variables: [...expression.variables, ...added]),
    );
  }

  /// The check of [expression]'s text, or null without a project: the check
  /// is project scoped, so nothing is asked then.
  static ReduxAction<AppState>? _validation(
    String? projectId,
    ExpressionModel expression,
  ) => projectId == null
      ? null
      : ValidateExpressionAction(
          expression.expression,
          variableNames(expression),
        );
}

class _ExpressionGeneralView extends Vm {
  _ExpressionGeneralView({
    required this.selected,
    required this.catalog,
    required this.projectId,
    required this.validation,
  }) : super(equals: [selected, catalog, projectId, validation]);

  final ExpressionModel selected;
  final ExpressionCatalog? catalog;
  final String? projectId;

  /// The backend's check of [selected]'s text, null when there is none for it.
  final ExpressionValidation? validation;
}

class _ExpressionGeneralFactory
    extends VmFactory<AppState, ExpressionGeneralPage, _ExpressionGeneralView> {
  @override
  _ExpressionGeneralView fromStore() {
    final selected = state.selectedExpression!;
    return _ExpressionGeneralView(
      selected: selected,
      catalog: state.expressionCatalog,
      projectId: state.selectedProject?.id,
      validation: ExpressionValidationState.forModel(
        state.expressionValidation,
        selected,
      ),
    );
  }
}
