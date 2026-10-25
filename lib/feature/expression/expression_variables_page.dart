import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression/selected_expression_state.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/expression/expression_stage.dart';
import 'package:stelaris/feature/expression/expression_variable_dialog.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The variables of the expression, each a card that edits it in a dialog.
/// Every change is staged on the expression; saving is up to the header.
class ExpressionVariablesPage extends StatelessWidget {
  const ExpressionVariablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedExpressionView>(
      vm: () => SelectedExpressionState(),
      builder: (context, vm) {
        final expression = vm.selected;
        final variables = expression.variables;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                child: ActionChip(
                  avatar: const Icon(Icons.add),
                  label: Text(context.l10n.button_add),
                  onPressed: () => _add(context, expression),
                ),
              ),
              const SizedBox(height: 16),
              if (variables.isEmpty)
                Expanded(
                  child: EmptyDataWidget.full(
                    header: context.l10n.expression_variables_empty_header,
                    subHeader:
                        context.l10n.expression_variables_empty_subheader,
                    icon: Icons.data_object,
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: variables.length,
                    itemBuilder: (context, index) => _VariableCard(
                      variable: variables[index],
                      onEdit: () => _edit(context, expression, index),
                      onDelete: () => _delete(context, expression, index),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// The names of the variables other than the one at [except].
  static List<String> _namesExcept(
    List<ExpressionVariable> variables, [
    int? except,
  ]) => [
    for (final (index, variable) in variables.indexed)
      if (index != except) variable.name,
  ];

  static Future<void> _add(
    BuildContext context,
    ExpressionModel expression,
  ) async {
    final variable = await showExpressionVariableDialog(
      context,
      taken: _namesExcept(expression.variables),
    );
    if (variable == null || !context.mounted) return;
    stageExpression(
      context,
      expression.copyWith(variables: [...expression.variables, variable]),
    );
  }

  static Future<void> _edit(
    BuildContext context,
    ExpressionModel expression,
    int index,
  ) async {
    final variables = expression.variables;
    final variable = await showExpressionVariableDialog(
      context,
      variable: variables[index],
      taken: _namesExcept(variables, index),
    );
    if (variable == null || !context.mounted) return;
    stageExpression(
      context,
      expression.copyWith(
        variables: [
          for (final (i, current) in variables.indexed)
            if (i == index) variable else current,
        ],
      ),
    );
  }

  static Future<void> _delete(
    BuildContext context,
    ExpressionModel expression,
    int index,
  ) async {
    final variables = expression.variables;
    final variable = variables[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteDialog<ExpressionVariable>(
        title: context.l10n.expression_variable_delete_title,
        header: [
          TextSpan(
            text: variable.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
        value: variable,
        successfully: (_) => true,
      ),
    );
    if (confirmed != true || !context.mounted) return;
    stageExpression(
      context,
      expression.copyWith(
        variables: [
          for (final (i, current) in variables.indexed)
            if (i != index) current,
        ],
      ),
    );
  }
}

/// One variable: its name, with its type and test value below it.
class _VariableCard extends StatelessWidget {
  const _VariableCard({
    required this.variable,
    required this.onEdit,
    required this.onDelete,
  });

  final ExpressionVariable variable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final testValue = variable.testValue;
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
            variable.name,
            style: const TextStyle(fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${expressionVariableTypeLabel(l10n, variable.type)} · '
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
