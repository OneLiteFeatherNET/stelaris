import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression/selected_expression_state.dart';
import 'package:stelaris/feature/expression/expression_stage.dart';
import 'package:stelaris/feature/expression/expression_variable_list_editor.dart';
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
        final l10n = context.l10n;
        final expression = vm.selected;
        return ExpressionVariableListEditor(
          variables: expression.variables,
          onChanged: (variables) => stageExpression(
            context,
            expression.copyWith(variables: variables),
          ),
          emptyHeader: l10n.expression_variables_empty_header,
          emptySubheader: l10n.expression_variables_empty_subheader,
          deleteTitle: l10n.expression_variable_delete_title,
        );
      },
    );
  }
}
