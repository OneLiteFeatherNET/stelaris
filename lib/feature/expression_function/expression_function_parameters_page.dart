import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression_function/selected_expression_function_state.dart';
import 'package:stelaris/feature/expression/expression_variable_list_editor.dart';
import 'package:stelaris/feature/expression_function/expression_function_stage.dart';
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
        return ExpressionVariableListEditor(
          variables: function.parameters,
          onChanged: (parameters) => stageExpressionFunction(
            context,
            function.copyWith(parameters: parameters),
          ),
          emptyHeader: l10n.expression_function_parameters_empty_header,
          emptySubheader: l10n.expression_function_parameters_empty_subheader,
          deleteTitle: l10n.expression_function_parameter_delete_title,
          parameter: true,
          problems: violationsFor(vm.problem, 'parameters'),
        );
      },
    );
  }
}
