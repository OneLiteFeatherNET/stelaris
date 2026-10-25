import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression/selected_expression_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/feature/expression/expression_variable_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The expression's Test tab: the expression as it is now, possibly unsaved,
/// evaluated with values typed in here. The values are not stored.
class ExpressionTestPage extends StatefulWidget {
  const ExpressionTestPage({super.key});

  @override
  State<ExpressionTestPage> createState() => _ExpressionTestPageState();
}

class _ExpressionTestPageState extends State<ExpressionTestPage> {
  /// One input per variable name, pre-filled from its test value the first
  /// time it is shown. Kept while the page is open.
  final Map<String, TextEditingController> _inputs = {};

  /// Counts the evaluations started. An answer to an older press is dropped.
  int _evaluation = 0;
  bool _running = false;
  ExpressionResult? _result;

  /// The backend rejected the expression or a variable, with its violations.
  ProblemDetail? _rejection;
  bool _failed = false;

  @override
  void dispose() {
    for (final input in _inputs.values) {
      input.dispose();
    }
    super.dispose();
  }

  TextEditingController _inputFor(ExpressionVariable variable) =>
      _inputs.putIfAbsent(
        variable.name,
        () => TextEditingController(text: variable.testValue ?? ''),
      );

  /// The variables with the values typed in, which the request carries.
  List<ExpressionVariable> _enteredVariables(
    List<ExpressionVariable> variables,
  ) => [
    for (final variable in variables)
      variable.copyWith(testValue: _inputFor(variable).text),
  ];

  Future<void> _evaluate(SelectedExpressionView vm) async {
    final projectId = vm.projectId;
    if (projectId == null) return;
    final evaluation = ++_evaluation;
    setState(() {
      _running = true;
      _result = null;
      _rejection = null;
      _failed = false;
    });
    try {
      final result = await ApiService().expressionApi.evaluate(
        projectId,
        vm.selected.expression,
        _enteredVariables(vm.selected.variables),
      );
      if (!mounted || evaluation != _evaluation) return;
      setState(() {
        _running = false;
        _result = result;
      });
    } on ProblemDetail catch (problem) {
      if (!mounted || evaluation != _evaluation) return;
      setState(() {
        _running = false;
        _rejection = problem;
      });
    } catch (_) {
      if (!mounted || evaluation != _evaluation) return;
      setState(() {
        _running = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedExpressionView>(
      vm: () => SelectedExpressionState(),
      builder: (context, vm) {
        final l10n = context.l10n;
        final expression = vm.selected;
        final canEvaluate =
            expression.expression.trim().isNotEmpty && vm.projectId != null;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EditSectionHeading(
                title: l10n.expression_test_section_expression,
              ),
              const SizedBox(height: 8),
              SelectableText(
                expression.expression,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
              ),
              const SizedBox(height: 24),
              EditSectionHeading(title: l10n.expression_test_section_variables),
              const SizedBox(height: 8),
              if (expression.variables.isEmpty)
                Text(l10n.expression_test_no_variables)
              else
                for (final variable in expression.variables)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      key: ValueKey(variable.name),
                      controller: _inputFor(variable),
                      decoration: InputDecoration(
                        labelText: variable.name,
                        helperText: expressionVariableTypeLabel(
                          l10n,
                          variable.type,
                        ),
                        prefixIcon: const Icon(Icons.data_object),
                      ),
                    ),
                  ),
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.expression_test_evaluate),
                onPressed: canEvaluate ? () => _evaluate(vm) : null,
              ),
              if (expression.expression.trim().isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.expression_test_empty_hint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 24),
              _outcome(context, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _outcome(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final errorStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.error,
    );
    if (_running) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failed) {
      return Text(l10n.expression_test_error, style: errorStyle);
    }
    final rejection = _rejection;
    if (rejection != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.expression_test_rejected, style: errorStyle),
          const SizedBox(height: 8),
          if (rejection.errors.isEmpty)
            Text(rejection.displayMessage, style: errorStyle)
          else
            for (final error in rejection.errors)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      error.field,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    Text(error.message, style: errorStyle),
                  ],
                ),
              ),
        ],
      );
    }
    final result = _result;
    if (result != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.expression_test_result_label,
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          SelectableText(
            result.value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.expression_test_result_type(result.type),
            style: theme.textTheme.bodySmall,
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
