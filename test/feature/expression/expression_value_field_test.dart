import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/expression/expression_preview.dart';
import 'package:stelaris/feature/expression/expression_variable_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/pump_in_app.dart';

void main() {
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

  Future<void> pumpPreview(
    WidgetTester tester,
    List<ExpressionVariable> variables,
  ) => pumpInApp(
    tester,
    Store<AppState>(
      initialState: AppState(
        selectedExpression: ExpressionModel(
          uiName: 'Test',
          id: 'e1',
          projectId: 'p1',
          expression: 'a',
          variables: variables,
        ),
      ),
    ),
    const ExpressionPreview(),
  );

  testWidgets('a number variable in the preview takes no letters', (
    tester,
  ) async {
    await pumpPreview(tester, const [ExpressionVariable(name: 'a')]);

    await tester.enterText(find.byType(TextFormField), 'abc');
    await tester.pump();
    expect(find.text('abc'), findsNothing);

    await tester.enterText(find.byType(TextFormField), '-1.5');
    await tester.pump();
    expect(find.text('-1.5'), findsOneWidget);
    await tester.pump(expressionPreviewDebounce);
  });

  testWidgets('a string variable in the preview takes letters', (tester) async {
    await pumpPreview(tester, const [
      ExpressionVariable(name: 'a', type: ExpressionValueType.string),
    ]);

    await tester.enterText(find.byType(TextFormField), 'abc');
    await tester.pump();
    expect(find.text('abc'), findsOneWidget);
    await tester.pump(expressionPreviewDebounce);
  });

  testWidgets('a stored invalid number blocks the evaluation', (tester) async {
    await pumpPreview(tester, const [
      ExpressionVariable(name: 'a', testValue: 'abc'),
    ]);

    await tester.pump(expressionPreviewDebounce);
    await tester.pump();

    expect(find.text(l10n.validation_number_invalid), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('the variable dialog takes no letters as a number test value', (
    tester,
  ) async {
    await pumpInApp(
      tester,
      Store<AppState>(initialState: const AppState()),
      const ExpressionVariableDialog(taken: []),
    );

    final testValue = find.byType(TextFormField).last;
    await tester.enterText(testValue, 'x1');
    await tester.pump();
    expect(find.text('x1'), findsNothing);

    await tester.enterText(testValue, '-');
    await tester.pump();
    expect(find.text(l10n.validation_number_invalid), findsOneWidget);
  });
}
