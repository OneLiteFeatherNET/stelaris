import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/app_state.dart';
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

/// The function's General tab: its name and signature, and its body. A
/// formula's body is edited in place with the parameters suggested; an
/// interface's body is only an optional stub the Test tab evaluates.
///
/// The backend's rejection of the last save is shown at the field it names.
/// The name is also checked as it is typed, so a bad identifier shows before
/// a save.
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
        final isInterface = function.kind == ExpressionFunctionKind.INTERFACE;
        final problem = vm.problem;
        final nameError =
            _first(violationsFor(problem, 'name')) ??
            (expressionVariableNamePattern.hasMatch(function.name)
                ? null
                : l10n.expression_function_name_invalid);
        final returnError = _first(violationsFor(problem, 'returnType'));
        final bodyErrors = violationsFor(problem, 'body');

        void stage(ExpressionFunctionModel changed) =>
            stageExpressionFunction(context, changed);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            EditSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EditSectionHeading(
                    title: l10n.expression_function_section_signature,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: ValueKey('expression_function_ui_name_${function.id}'),
                    initialValue: function.uiName,
                    decoration: InputDecoration(
                      labelText: l10n.expression_function_field_ui_name,
                      prefixIcon: const Icon(Icons.title),
                    ),
                    onChanged: (value) =>
                        stage(function.copyWith(uiName: value)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: ValueKey(
                      'expression_function_identifier_${function.id}',
                    ),
                    initialValue: function.name,
                    style: const TextStyle(fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      labelText: l10n.expression_function_field_name,
                      helperText: l10n.expression_function_field_name_hint,
                      errorText: nameError,
                      prefixIcon: const Icon(Icons.functions),
                    ),
                    onChanged: (value) => stage(function.copyWith(name: value)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.expression_function_field_kind,
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  SegmentedButton<ExpressionFunctionKind>(
                    segments: [
                      ButtonSegment(
                        value: ExpressionFunctionKind.FORMULA,
                        label: Text(l10n.expression_function_kind_formula),
                        icon: const Icon(Icons.functions),
                      ),
                      ButtonSegment(
                        value: ExpressionFunctionKind.INTERFACE,
                        label: Text(l10n.expression_function_kind_interface),
                        icon: const Icon(
                          Icons.integration_instructions_outlined,
                        ),
                      ),
                    ],
                    selected: {function.kind},
                    onSelectionChanged: (kinds) =>
                        stage(function.copyWith(kind: kinds.first)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isInterface
                        ? l10n.expression_function_kind_interface_hint
                        : l10n.expression_function_kind_formula_hint,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ExpressionFunctionReturnType>(
                    initialValue: function.returnType,
                    decoration: InputDecoration(
                      labelText: l10n.expression_function_field_return_type,
                      errorText: returnError,
                      prefixIcon: const Icon(Icons.keyboard_return),
                    ),
                    items: [
                      for (final type in ExpressionFunctionReturnType.values)
                        DropdownMenuItem(
                          value: type,
                          child: Text(_returnTypeLabel(l10n, type)),
                        ),
                    ],
                    onChanged: (type) {
                      if (type != null) {
                        stage(function.copyWith(returnType: type));
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: ValueKey('expression_function_comment_${function.id}'),
                    initialValue: function.comment ?? '',
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.expression_function_field_comment,
                      prefixIcon: const Icon(Icons.notes),
                    ),
                    onChanged: (value) => stage(
                      function.copyWith(comment: value.isEmpty ? null : value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            EditSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EditSectionHeading(
                    title: isInterface
                        ? l10n.expression_function_section_stub
                        : l10n.expression_function_section_body,
                  ),
                  const SizedBox(height: 8),
                  if (isInterface) ...[
                    Text(
                      l10n.expression_function_stub_hint,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if ((function.body ?? '').trim().isNotEmpty) ...[
                    Text(
                      l10n.expression_rendered_formula_label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ExpressionMathView(
                      formula: _signatureText(function),
                      tex: functionToTex(
                        function.name,
                        [
                          for (final parameter in function.parameters)
                            parameter.name,
                        ],
                        function.body ?? '',
                        functionNames: catalogFunctionNames(vm.catalog),
                      ),
                      fontSize: 16,
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Keyed, so the field keeps its focus and text when the rendered
                  // line above it comes and goes.
                  ExpressionFormulaField(
                    key: const ValueKey('expression_formula_field'),
                    expression: ExpressionModel(
                      uiName: function.uiName,
                      id: function.id,
                      expression: function.body ?? '',
                      variables: function.parameters,
                    ),
                    catalog: vm.catalog,
                    onChanged: (value) => stage(function.copyWith(body: value)),
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

  static String _returnTypeLabel(
    AppLocalizations l10n,
    ExpressionFunctionReturnType type,
  ) => switch (type) {
    ExpressionFunctionReturnType.NUMBER =>
      l10n.expression_function_return_number,
    ExpressionFunctionReturnType.BOOLEAN =>
      l10n.expression_function_return_boolean,
    ExpressionFunctionReturnType.STRING =>
      l10n.expression_function_return_string,
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
