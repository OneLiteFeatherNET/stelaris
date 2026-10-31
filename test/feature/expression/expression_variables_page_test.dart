import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/expression/expression_variables_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/pump_in_app.dart';

const _radius = ExpressionVariable(name: 'radius', testValue: '2');

Store<AppState> _storeWith(List<ExpressionVariable> variables) =>
    Store<AppState>(
      initialState: AppState(
        selectedExpression: ExpressionModel(
          uiName: 'Area',
          id: 'e1',
          expression: 'PI * radius ^ 2',
          variables: variables,
        ),
      ),
    );

/// Adds a variable named [name] through the Add chip and the dialog's Save.
Future<void> _addVariable(WidgetTester tester, String name) async {
  await tester.tap(find.text('Add'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find
        .descendant(
          of: find.byType(Dialog),
          matching: find.byType(TextFormField),
        )
        .first,
    name,
  );
  await tester.tap(
    find.descendant(of: find.byType(Dialog), matching: find.text('Save')),
  );
  await tester.pumpAndSettle();
}

void main() {
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('adding a variable stages it on the expression as unsaved', (
    tester,
  ) async {
    final store = _storeWith([]);
    await pumpInApp(tester, store, const ExpressionVariablesPage());

    await _addVariable(tester, 'height');

    expect(store.state.selectedExpression?.variables.map((v) => v.name), [
      'height',
    ]);
    expect(
      store.state.selectedExpression?.variables.single.type,
      ExpressionValueType.number,
    );
    expect(store.state.unsavedChanges, NavigationEntry.expression);
  });

  testWidgets(
    'a name another variable already has is rejected with the error',
    (tester) async {
      final store = _storeWith([_radius]);
      await pumpInApp(tester, store, const ExpressionVariablesPage());

      await _addVariable(tester, 'radius');

      expect(
        find.text(l10n.expression_variable_name_duplicate('radius')),
        findsOneWidget,
      );
      expect(find.byType(Dialog), findsOneWidget);
      expect(store.state.selectedExpression?.variables, [_radius]);
    },
  );

  testWidgets('a name that is not an identifier is rejected with the error', (
    tester,
  ) async {
    final store = _storeWith([]);
    await pumpInApp(tester, store, const ExpressionVariablesPage());

    await _addVariable(tester, '1radius');

    expect(find.text(l10n.expression_variable_name_invalid), findsOneWidget);
    expect(store.state.selectedExpression?.variables, isEmpty);
  });

  testWidgets('deleting a variable after confirming removes it', (
    tester,
  ) async {
    final store = _storeWith([_radius]);
    await pumpInApp(tester, store, const ExpressionVariablesPage());

    await tester.tap(find.byTooltip(l10n.tooltip_delete));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text(l10n.tooltip_delete),
      ),
    );
    await tester.pumpAndSettle();

    expect(store.state.selectedExpression?.variables, isEmpty);
    expect(store.state.unsavedChanges, NavigationEntry.expression);
  });

  testWidgets('an expression without variables shows the empty state', (
    tester,
  ) async {
    await pumpInApp(tester, _storeWith([]), const ExpressionVariablesPage());

    expect(find.text(l10n.expression_variables_empty_header), findsOneWidget);
  });
}
