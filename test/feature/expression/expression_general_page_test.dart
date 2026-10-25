import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/expression/expression_general_page.dart';

import '../../support/edit_card.dart';
import '../../support/pump_in_app.dart';

void main() {
  testWidgets('editing the expression stages it in the store as unsaved', (
    tester,
  ) async {
    final store = Store<AppState>(
      initialState: const AppState(
        selectedExpression: ExpressionModel(
          uiName: 'Damage',
          id: 'e1',
          expression: 'a * 2',
        ),
      ),
    );
    await pumpInApp(tester, store, const ExpressionGeneralPage());

    await editCard(tester, 'Expression', 'a * 2 + sqrt(b)');

    expect(store.state.selectedExpression?.expression, 'a * 2 + sqrt(b)');
    expect(store.state.unsavedChanges, NavigationEntry.expression);
  });
}
