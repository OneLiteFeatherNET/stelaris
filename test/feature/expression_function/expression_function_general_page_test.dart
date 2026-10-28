import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/api/model/expression_function_model.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/expression_function/expression_function_general_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/pump_in_app.dart';

const _project = Project(id: 'p1', displayName: 'P1', key: 'p1');
const _identifierField = ValueKey('expression_function_identifier_f1');

ExpressionFunctionModel _function({
  ExpressionFunctionKind kind = ExpressionFunctionKind.FORMULA,
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

    await tester.tap(find.text(l10n.expression_function_kind_interface));
    await tester.pumpAndSettle();

    expect(
      store.state.selectedExpressionFunction?.kind,
      ExpressionFunctionKind.INTERFACE,
    );
    expect(find.text(l10n.expression_function_section_stub), findsOneWidget);
  });

  testWidgets('a rejected name shows its message under the identifier field', (
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
    await _pump(tester);

    await tester.enterText(find.byKey(_identifierField), '3d_hit');
    await tester.pumpAndSettle();

    expect(find.text(l10n.expression_function_name_invalid), findsOneWidget);
  });
}
