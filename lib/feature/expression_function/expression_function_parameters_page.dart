import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/expression_function_model.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression_function/selected_expression_function_state.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/expression/expression_variable_dialog.dart';
import 'package:stelaris/feature/expression_function/expression_function_stage.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The parameters of the function, each a card that edits it in a dialog. A
/// formula's body suggests them, and the Test tab takes a value for each.
/// Every change is staged on the function; saving is up to the header.
class ExpressionFunctionParametersPage extends StatelessWidget {
  const ExpressionFunctionParametersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedExpressionFunctionView>(
      vm: () => SelectedExpressionFunctionState(),
      builder: (context, vm) {
        final l10n = context.l10n;
        final function = vm.selected;
        final parameters = function.parameters;
        final problems = violationsFor(vm.problem, 'parameters');
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final message in problems)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Align(
                child: ActionChip(
                  avatar: const Icon(Icons.add),
                  label: Text(l10n.button_add),
                  onPressed: () => _add(context, function),
                ),
              ),
              const SizedBox(height: 16),
              if (parameters.isEmpty)
                Expanded(
                  child: EmptyDataWidget.full(
                    header: l10n.expression_function_parameters_empty_header,
                    subHeader:
                        l10n.expression_function_parameters_empty_subheader,
                    icon: Icons.data_object,
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: parameters.length,
                    itemBuilder: (context, index) => _ParameterCard(
                      parameter: parameters[index],
                      onEdit: () => _edit(context, function, index),
                      onDelete: () => _delete(context, function, index),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// The names of the parameters other than the one at [except].
  static List<String> _namesExcept(
    List<ExpressionVariable> parameters, [
    int? except,
  ]) => [
    for (final (index, parameter) in parameters.indexed)
      if (index != except) parameter.name,
  ];

  static Future<void> _add(
    BuildContext context,
    ExpressionFunctionModel function,
  ) async {
    final parameter = await showExpressionVariableDialog(
      context,
      taken: _namesExcept(function.parameters),
      parameter: true,
    );
    if (parameter == null || !context.mounted) return;
    stageExpressionFunction(
      context,
      function.copyWith(parameters: [...function.parameters, parameter]),
    );
  }

  static Future<void> _edit(
    BuildContext context,
    ExpressionFunctionModel function,
    int index,
  ) async {
    final parameters = function.parameters;
    final parameter = await showExpressionVariableDialog(
      context,
      variable: parameters[index],
      taken: _namesExcept(parameters, index),
      parameter: true,
    );
    if (parameter == null || !context.mounted) return;
    stageExpressionFunction(
      context,
      function.copyWith(
        parameters: [
          for (final (i, current) in parameters.indexed)
            if (i == index) parameter else current,
        ],
      ),
    );
  }

  static Future<void> _delete(
    BuildContext context,
    ExpressionFunctionModel function,
    int index,
  ) async {
    final parameters = function.parameters;
    final parameter = parameters[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteDialog<ExpressionVariable>(
        title: context.l10n.expression_function_parameter_delete_title,
        header: [
          TextSpan(
            text: parameter.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
        value: parameter,
        successfully: (_) => true,
      ),
    );
    if (confirmed != true || !context.mounted) return;
    stageExpressionFunction(
      context,
      function.copyWith(
        parameters: [
          for (final (i, current) in parameters.indexed)
            if (i != index) current,
        ],
      ),
    );
  }
}

/// One parameter: its name, with its type and test value below it.
class _ParameterCard extends StatelessWidget {
  const _ParameterCard({
    required this.parameter,
    required this.onEdit,
    required this.onDelete,
  });

  final ExpressionVariable parameter;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final testValue = parameter.testValue;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Card.filled(
        margin: const EdgeInsets.symmetric(vertical: 4),
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.medium),
        ),
        child: ListTile(
          onTap: onEdit,
          leading: const Icon(Icons.data_object),
          title: Text(
            parameter.name,
            style: const TextStyle(fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${expressionVariableTypeLabel(l10n, parameter.type)} · '
            '${testValue == null || testValue.isEmpty ? l10n.expression_variable_no_test_value : testValue}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            tooltip: l10n.tooltip_delete,
            onPressed: onDelete,
            icon: const Icon(Icons.delete_forever),
          ),
        ),
      ),
    );
  }
}
