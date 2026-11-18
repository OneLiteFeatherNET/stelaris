import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/expression/expression_variable_dialog.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The variables of an expression or the parameters of a function, each a
/// card that edits it in a dialog.
///
/// Every change is reported as the whole new list through [onChanged], the
/// caller stages it. A dismissed dialog reports nothing. [parameter] words
/// the dialogs for a parameter, [problems] are shown above the list.
class ExpressionVariableListEditor extends StatelessWidget {
  const ExpressionVariableListEditor({
    required this.variables,
    required this.onChanged,
    required this.emptyHeader,
    required this.emptySubheader,
    required this.deleteTitle,
    this.parameter = false,
    this.problems = const [],
    super.key,
  });

  final List<ExpressionVariable> variables;
  final ValueChanged<List<ExpressionVariable>> onChanged;
  final String emptyHeader;
  final String emptySubheader;

  /// The title of the dialog that confirms a deletion.
  final String deleteTitle;
  final bool parameter;
  final List<String> problems;

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Align(
            child: ActionChip(
              avatar: const Icon(Icons.add),
              label: Text(context.l10n.button_add),
              onPressed: () => _add(context),
            ),
          ),
          const SizedBox(height: 16),
          if (variables.isEmpty)
            Expanded(
              child: EmptyDataWidget.full(
                header: emptyHeader,
                subHeader: emptySubheader,
                icon: Icons.data_object,
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: variables.length,
                itemBuilder: (context, index) => _VariableCard(
                  variable: variables[index],
                  onEdit: () => _edit(context, index),
                  onDelete: () => _delete(context, index),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// The names of the variables other than the one at [except].
  List<String> _namesExcept([int? except]) => [
    for (final (index, variable) in variables.indexed)
      if (index != except) variable.name,
  ];

  Future<void> _add(BuildContext context) async {
    final variable = await showExpressionVariableDialog(
      context,
      taken: _namesExcept(),
      parameter: parameter,
    );
    if (variable == null || !context.mounted) return;
    onChanged([...variables, variable]);
  }

  Future<void> _edit(BuildContext context, int index) async {
    final variable = await showExpressionVariableDialog(
      context,
      variable: variables[index],
      taken: _namesExcept(index),
      parameter: parameter,
    );
    if (variable == null || !context.mounted) return;
    onChanged([
      for (final (i, current) in variables.indexed)
        if (i == index) variable else current,
    ]);
  }

  Future<void> _delete(BuildContext context, int index) async {
    final variable = variables[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteDialog<ExpressionVariable>(
        title: deleteTitle,
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
    onChanged([
      for (final (i, current) in variables.indexed)
        if (i != index) current,
    ]);
  }
}

/// One variable or parameter: its name, with its type and test value below
/// it.
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
