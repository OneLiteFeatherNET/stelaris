import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_card_grid.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_card.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/feature/expression/expression_formula_field.dart';
import 'package:stelaris/feature/expression/expression_math_view.dart';
import 'package:stelaris/feature/expression/expression_tex.dart';
import 'package:stelaris/feature/expression/expression_variable_dialog.dart';
import 'package:stelaris/feature/expression_function/expression_function_stage.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The function's General tab: its signature as edit cards, each changed in
/// its dialog, and below them its body. A formula's body is edited in place
/// with the parameters suggested; an interface's body is only an optional
/// stub the Test tab evaluates.
///
/// The backend's rejection of the last save is shown on the card of the field
/// it names. The name dialog also checks the identifier, so a bad one cannot
/// be saved.
class ExpressionFunctionGeneralPage extends StatelessWidget {
  const ExpressionFunctionGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ExpressionFunctionGeneralView>(
      vm: () => _ExpressionFunctionGeneralFactory(),
      builder: (context, vm) {
        final l10n = context.l10n;
        final theme = Theme.of(context);
        final function = vm.selected;
        final isInterface = function.kind == ExpressionFunctionKind.interface;
        final problem = vm.problem;
        final bodyErrors = violationsFor(problem, 'body');

        void stage(ExpressionFunctionModel changed) =>
            stageExpressionFunction(context, changed);

        return EditCardGrid(
          sections: [
            EditSection(
              title: l10n.expression_function_section_signature,
              fields: [
                // No card for the display name: like every model's, it is
                // fixed once the function is created. The name is the one
                // formulas call the function by in game.
                TextEdit(
                  label: l10n.expression_function_field_name,
                  icon: Icons.functions,
                  value: function.name,
                  footer:
                      _first(violationsFor(problem, 'name')) ??
                      l10n.expression_function_field_name_hint,
                  validator: (value) =>
                      expressionVariableNamePattern.hasMatch(value ?? '')
                      ? null
                      : l10n.expression_function_name_invalid,
                  onChanged: (value) => stage(function.copyWith(name: value)),
                ),
                ChoiceEdit<ExpressionFunctionKind>(
                  label: l10n.expression_function_field_kind,
                  icon: isInterface
                      ? Icons.integration_instructions_outlined
                      : Icons.functions,
                  value: function.kind,
                  options: ExpressionFunctionKind.values,
                  display: (kind) => _kindLabel(l10n, kind),
                  footer: isInterface
                      ? l10n.expression_function_kind_interface_hint
                      : l10n.expression_function_kind_formula_hint,
                  onChanged: (kind) => stage(function.copyWith(kind: kind)),
                ),
                ChoiceEdit<ExpressionValueType>(
                  label: l10n.expression_function_field_return_type,
                  icon: Icons.keyboard_return,
                  value: function.returnType,
                  options: ExpressionValueType.values,
                  display: (type) => _returnTypeLabel(l10n, type),
                  footer: _first(violationsFor(problem, 'returnType')),
                  onChanged: (type) =>
                      stage(function.copyWith(returnType: type)),
                ),
                TextEdit(
                  label: l10n.expression_function_field_comment,
                  icon: Icons.notes,
                  value: function.comment ?? '',
                  onChanged: (value) => stage(
                    function.copyWith(comment: value.isEmpty ? null : value),
                  ),
                ),
              ],
            ),
          ],
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EditSectionHeading(
                title: isInterface
                    ? l10n.expression_function_section_stub
                    : l10n.expression_function_section_body,
              ),
              const SizedBox(height: 8),
              EditSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isInterface) ...[
                      Text(
                        l10n.expression_function_stub_hint,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Keyed, so the field keeps its focus and text when the
                    // section above it changes.
                    ExpressionFormulaField(
                      key: const ValueKey('expression_formula_field'),
                      expression: ExpressionModel(
                        uiName: function.uiName,
                        id: function.id,
                        expression: function.body ?? '',
                        variables: function.parameters,
                      ),
                      catalog: vm.catalog,
                      onChanged: (value) =>
                          stage(function.copyWith(body: value)),
                    ),
                    // Below the editor, so the line being typed stays put
                    // while the typeset function grows.
                    AnimatedSize(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOutCubic,
                      alignment: AlignmentDirectional.topStart,
                      child: (function.body ?? '').trim().isEmpty
                          ? const SizedBox(width: double.infinity)
                          : Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: ExpressionMathPanel(
                                label: l10n.expression_rendered_formula_label,
                                child: _FunctionMath(
                                  function: function,
                                  catalog: vm.catalog,
                                  fontSize: ExpressionMathPanel.fontSize,
                                ),
                              ),
                            ),
                    ),
                    for (final message in bodyErrors)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// The function as text, `name(parameters) = body`, shown when it does not
  /// convert to math.
  static String _signatureText(ExpressionFunctionModel function) {
    final parameters = [
      for (final parameter in function.parameters) parameter.name,
    ];
    return '${function.name}(${parameters.join(', ')}) = ${function.body ?? ''}';
  }

  static String? _first(List<String> messages) =>
      messages.isEmpty ? null : messages.first;

  static String _kindLabel(
    AppLocalizations l10n,
    ExpressionFunctionKind kind,
  ) => switch (kind) {
    ExpressionFunctionKind.formula => l10n.expression_function_kind_formula,
    ExpressionFunctionKind.interface => l10n.expression_function_kind_interface,
  };

  static String _returnTypeLabel(
    AppLocalizations l10n,
    ExpressionValueType type,
  ) => switch (type) {
    ExpressionValueType.number => l10n.expression_function_return_number,
    ExpressionValueType.boolean => l10n.expression_function_return_boolean,
    ExpressionValueType.string => l10n.expression_function_return_string,
  };
}

class _ExpressionFunctionGeneralView extends Vm {
  _ExpressionFunctionGeneralView({
    required this.selected,
    required this.catalog,
    required this.problem,
  }) : super(equals: [selected, catalog, problem]);

  final ExpressionFunctionModel selected;
  final ExpressionCatalog? catalog;
  final ProblemDetail? problem;
}

class _ExpressionFunctionGeneralFactory
    extends
        VmFactory<
          AppState,
          ExpressionFunctionGeneralPage,
          _ExpressionFunctionGeneralView
        > {
  @override
  _ExpressionFunctionGeneralView fromStore() => _ExpressionFunctionGeneralView(
    selected: state.selectedExpressionFunction!,
    catalog: state.expressionCatalog,
    problem: state.expressionFunctionProblem,
  );
}

/// The function's signature and body typeset as math. Its LaTeX is made again
/// only when the name, the parameters, the body or the catalog changes, not on
/// every rebuild of the page while the body is typed.
class _FunctionMath extends StatefulWidget {
  const _FunctionMath({
    required this.function,
    required this.catalog,
    required this.fontSize,
  });

  final ExpressionFunctionModel function;
  final ExpressionCatalog? catalog;
  final double fontSize;

  @override
  State<_FunctionMath> createState() => _FunctionMathState();
}

class _FunctionMathState extends State<_FunctionMath> {
  ({
    String name,
    List<String> parameters,
    String body,
    ExpressionCatalog? catalog,
    String? tex,
  })?
  _memo;

  @override
  Widget build(BuildContext context) {
    final function = widget.function;
    final catalog = widget.catalog;
    final parameters = [
      for (final parameter in function.parameters) parameter.name,
    ];
    final body = function.body ?? '';
    final memo = _memo;
    if (memo == null ||
        memo.name != function.name ||
        !listEquals(memo.parameters, parameters) ||
        memo.body != body ||
        !identical(memo.catalog, catalog)) {
      _memo = (
        name: function.name,
        parameters: parameters,
        body: body,
        catalog: catalog,
        tex: functionToTex(
          function.name,
          parameters,
          body,
          functionNames: catalogFunctionNames(catalog),
        ),
      );
    }
    return ExpressionMathView(
      formula: ExpressionFunctionGeneralPage._signatureText(function),
      tex: _memo!.tex,
      fontSize: widget.fontSize,
    );
  }
}
