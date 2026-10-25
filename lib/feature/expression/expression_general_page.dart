import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression/selected_expression_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/feature/expression/expression_formula_field.dart';
import 'package:stelaris/feature/expression/expression_stage.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The expression's General tab: its formula, edited in place with variable
/// suggestions. The backend checks the formula on save, so nothing is parsed
/// here.
class ExpressionGeneralPage extends StatelessWidget {
  const ExpressionGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedExpressionView>(
      vm: () => SelectedExpressionState(),
      builder: (context, vm) {
        final expression = vm.selected;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            EditSectionHeading(title: context.l10n.expression_section_formula),
            const SizedBox(height: 8),
            ExpressionFormulaField(
              expression: expression,
              onChanged: (value) => stageExpression(
                context,
                expression.copyWith(expression: value),
              ),
            ),
          ],
        );
      },
    );
  }
}
