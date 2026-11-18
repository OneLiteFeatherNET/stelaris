import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/expression_function/expression_function_parameters_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/pump_in_app.dart';

final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

Store<AppState> _storeWith(
  List<ExpressionVariable> parameters, {
  ProblemDetail? problem,
}) => Store<AppState>(
  initialState: AppState(
    selectedExpressionFunction: ExpressionFunctionModel(
      id: 'f1',
      uiName: 'Hit',
      name: 'hit',
      kind: ExpressionFunctionKind.formula,
      projectId: 'p1',
      parameters: parameters,
    ),
    expressionFunctionProblem: problem,
  ),
);

void main() {
  group('function parameters page', () {
    testWidgets('adding a parameter stages it on the function as unsaved', (
      tester,
    ) async {
      final store = _storeWith([]);
      await pumpInApp(tester, store, const ExpressionFunctionParametersPage());

      await tester.tap(find.text(l10n.button_add));
      await tester.pumpAndSettle();
      await tester.enterText(
        find
            .descendant(
              of: find.byType(Dialog),
              matching: find.byType(TextFormField),
            )
            .first,
        'damage',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text(l10n.button_add),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        store.state.selectedExpressionFunction?.parameters.map((p) => p.name),
        ['damage'],
      );
      expect(store.state.unsavedChanges, NavigationEntry.function);
    });

    testWidgets('the dialog is worded for a parameter', (tester) async {
      await pumpInApp(
        tester,
        _storeWith([]),
        const ExpressionFunctionParametersPage(),
      );

      await tester.tap(find.text(l10n.button_add));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.expression_function_parameter_add_title),
        findsOneWidget,
      );
    });

    testWidgets('shows the problems of the parameters', (tester) async {
      await pumpInApp(
        tester,
        _storeWith(
          [const ExpressionVariable(name: 'damage')],
          problem: const ProblemDetail(
            title: 'Bad',
            status: 400,
            errors: [
              ProblemValidationError(
                field: 'parameters[0].name',
                message: 'taken',
              ),
            ],
          ),
        ),
        const ExpressionFunctionParametersPage(),
      );

      expect(find.text('taken'), findsOneWidget);
    });

    testWidgets('a function without parameters shows the empty state', (
      tester,
    ) async {
      await pumpInApp(
        tester,
        _storeWith([]),
        const ExpressionFunctionParametersPage(),
      );

      expect(
        find.text(l10n.expression_function_parameters_empty_header),
        findsOneWidget,
      );
    });
  });
}
