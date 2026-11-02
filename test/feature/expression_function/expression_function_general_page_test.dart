import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/expression_function/expression_function_general_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/pump_in_app.dart';

const _project = Project(id: 'p1', displayName: 'P1', key: 'p1');

ExpressionFunctionModel _function({
  ExpressionFunctionKind kind = ExpressionFunctionKind.formula,
}) => ExpressionFunctionModel(
  id: 'f1',
  uiName: 'Damage bonus',
  name: 'damage_bonus',
  kind: kind,
  body: 'base * 2',
  parameters: const [ExpressionVariable(name: 'base')],
  projectId: 'p1',
);

Future<Store<AppState>> _pump(
  WidgetTester tester, {
  ExpressionFunctionModel? function,
  ProblemDetail? problem,
}) async {
  // A wide surface.
  tester.view
    ..physicalSize = const Size(1400, 1600)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  final store = Store<AppState>(
    initialState: AppState(
      selectedProject: _project,
      selectedExpressionFunction: function ?? _function(),
      expressionFunctionProblem: problem,
      expressionCatalog: const ExpressionCatalog(),
      expressionCatalogProjectId: 'p1',
    ),
  );
  await pumpInApp(tester, store, const ExpressionFunctionGeneralPage());
  return store;
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('the function is shown typeset above its body', (tester) async {
    await _pump(tester);

    expect(
      find.byType(Math),
      findsWidgets,
      reason: 'the signature name(params) = body is drawn as math',
    );
    expect(find.text(l10n.expression_rendered_formula_label), findsOneWidget);
  });

  testWidgets('a formula body is not labelled as a test stub', (tester) async {
    await _pump(tester);

    expect(find.text(l10n.expression_function_section_stub), findsNothing);
  });

  testWidgets('switching the kind to interface labels the body a test stub', (
    tester,
  ) async {
    final store = await _pump(tester);

    // The kind's card opens the list of kinds, a tap picks one.
    await tester.tap(find.text(l10n.expression_function_field_kind));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text(l10n.expression_function_kind_interface),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      store.state.selectedExpressionFunction?.kind,
      ExpressionFunctionKind.interface,
    );
    expect(find.text(l10n.expression_function_section_stub), findsOneWidget);
  });

  testWidgets('the display name has no card, it is fixed once created', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Damage bonus'), findsNothing);
  });

  testWidgets('a rejected name shows its message on the identifier card', (
    tester,
  ) async {
    await _pump(
      tester,
      problem: const ProblemDetail(
        title: 'Validation failed',
        status: 400,
        errors: [
          ProblemValidationError(field: 'name', message: 'Name is taken'),
        ],
      ),
    );

    expect(find.text('Name is taken'), findsOneWidget);
  });

  testWidgets('an identifier that starts with a digit is flagged as typed', (
    tester,
  ) async {
    final store = await _pump(tester);

    await tester.tap(find.text(l10n.expression_function_field_name));
    await tester.pumpAndSettle();
    final field = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(field, '3d_hit');
    await tester.pumpAndSettle();

    expect(find.text(l10n.expression_function_name_invalid), findsOneWidget);

    await tester.tap(find.text(l10n.button_save));
    await tester.pumpAndSettle();

    expect(
      store.state.selectedExpressionFunction?.name,
      'damage_bonus',
      reason: 'a bad identifier cannot be saved',
    );
  });

  testWidgets('a name saved in its dialog is staged', (tester) async {
    final store = await _pump(tester);

    await tester.tap(find.text(l10n.expression_function_field_name));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextFormField),
      ),
      'crit_bonus',
    );
    await tester.tap(find.text(l10n.button_save));
    await tester.pumpAndSettle();

    expect(store.state.selectedExpressionFunction?.name, 'crit_bonus');
    expect(store.state.selectedExpressionFunction?.uiName, 'Damage bonus');
  });
}
