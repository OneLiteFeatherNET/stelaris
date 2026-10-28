import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/expression_function_model.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression_function/selected_expression_function_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/feature/expression/expression_variable_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The function's Test tab: the function as it is now, possibly unsaved,
/// called with values typed in here. The values are not stored. An interface
/// is called through its test stub only.
class ExpressionFunctionTestPage extends StatefulWidget {
  const ExpressionFunctionTestPage({super.key});

  @override
  State<ExpressionFunctionTestPage> createState() =>
      _ExpressionFunctionTestPageState();
}

class _ExpressionFunctionTestPageState
    extends State<ExpressionFunctionTestPage> {
  /// One input per parameter name, pre-filled from its test value the first
  /// time it is shown. Kept while the page is open.
  final Map<String, TextEditingController> _inputs = {};

  /// Counts the evaluations started. An answer to an older press is dropped.
  int _evaluation = 0;
  bool _running = false;
  ExpressionResult? _result;

  /// The backend rejected the function or an argument, with its violations.
  ProblemDetail? _rejection;
  bool _failed = false;

  @override
  void dispose() {
    for (final input in _inputs.values) {
      input.dispose();
    }
    super.dispose();
  }

  TextEditingController _inputFor(ExpressionVariable parameter) =>
      _inputs.putIfAbsent(
        parameter.name,
        () => TextEditingController(text: parameter.testValue ?? ''),
      );

  /// The function with the parameters' test values as typed in here.
  ExpressionFunctionModel _enteredFunction(ExpressionFunctionModel function) =>
      function.copyWith(
        parameters: [
          for (final parameter in function.parameters)
            parameter.copyWith(testValue: _inputFor(parameter).text),
        ],
      );

  Future<void> _evaluate(SelectedExpressionFunctionView vm) async {
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
      final result = await ApiService().expressionFunctionApi.evaluate(
        projectId,
        _enteredFunction(vm.selected),
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
    return StoreConnector<AppState, SelectedExpressionFunctionView>(
      vm: () => SelectedExpressionFunctionState(),
      builder: (context, vm) {
        final l10n = context.l10n;
        final function = vm.selected;
        final body = function.body ?? '';
        final hasBody = body.trim().isNotEmpty;
        final isInterface = function.kind == ExpressionFunctionKind.INTERFACE;
        final canEvaluate = hasBody && vm.projectId != null;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EditSectionHeading(
                title: l10n.expression_function_test_section_body,
              ),
              const SizedBox(height: 8),
              if (hasBody)
                SelectableText(
                  body,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                )
              else
                Text(l10n.expression_function_test_no_body),
              const SizedBox(height: 24),
              EditSectionHeading(
                title: l10n.expression_function_test_section_parameters,
              ),
              const SizedBox(height: 8),
              if (function.parameters.isEmpty)
                Text(l10n.expression_function_test_no_parameters)
              else
                for (final parameter in function.parameters)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      key: ValueKey(parameter.name),
                      controller: _inputFor(parameter),
                      decoration: InputDecoration(
                        labelText: parameter.name,
                        helperText: expressionVariableTypeLabel(
                          l10n,
                          parameter.type,
                        ),
                        prefixIcon: const Icon(Icons.data_object),
                      ),
                    ),
                  ),
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.expression_function_test_evaluate),
                onPressed: canEvaluate ? () => _evaluate(vm) : null,
              ),
              if (!hasBody) ...[
                const SizedBox(height: 8),
                Text(
                  isInterface
                      ? l10n.expression_function_test_interface_hint
                      : l10n.expression_function_test_empty_hint,
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
      return Text(l10n.expression_function_test_error, style: errorStyle);
    }
    final rejection = _rejection;
    if (rejection != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.expression_function_test_rejected, style: errorStyle),
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
            l10n.expression_function_test_result_label,
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
            l10n.expression_function_test_result_type(result.type),
            style: theme.textTheme.bodySmall,
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
