import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression/selected_expression_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_card_grid.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/feature/expression/expression_stage.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The expression's General tab: its formula, a card that opens a dialog.
/// The backend checks the formula on save, so nothing is parsed here.
class ExpressionGeneralPage extends StatelessWidget {
  const ExpressionGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedExpressionView>(
      vm: () => SelectedExpressionState(),
      builder: (context, vm) {
        final l10n = context.l10n;
        final expression = vm.selected;
        return EditCardGrid(
          sections: [
            EditSection(
              title: l10n.expression_section_formula,
              fields: [
                TextEdit(
                  label: l10n.expression_field_expression,
                  icon: Icons.functions,
                  value: expression.expression,
                  footer: l10n.expression_hint_expression,
                  onChanged: (value) => stageExpression(
                    context,
                    expression.copyWith(expression: value),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
