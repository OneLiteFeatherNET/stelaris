import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/expression/expression_general_page.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/pump_until.dart';
import '../../support/pump_in_app.dart';

const Project _project = Project(id: 'p1', displayName: 'P1', key: 'p1');

const _catalog = ExpressionCatalog(
  constants: [CatalogConstant(name: 'PI', value: '3.14159')],
);

ExpressionModel _expression({String text = 'radius * 2'}) => ExpressionModel(
  uiName: 'Damage',
  id: 'e1',
  expression: text,
  variables: const [
    ExpressionVariable(name: 'radius'),
    ExpressionVariable(name: 'rate', type: ExpressionVariableType.BOOLEAN),
  ],
);

/// Answers every check with [answer] and keeps the bodies it was asked with.
class _AnsweringAdapter implements HttpClientAdapter {
  _AnsweringAdapter(this.answer);

  final Map<String, Object?> answer;
  final List<Map<String, dynamic>> asked = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    asked.add(Map<String, dynamic>.from(options.data as Map));
    return FakeHttpClientAdapter.response(answer);
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object?> _answer({
  bool valid = true,
  List<Map<String, Object?>> errors = const [],
  List<String> undefined = const [],
  List<String> unused = const [],
}) => {
  'valid': valid,
  'errors': errors,
  'usedVariables': <Object>[],
  'undefinedVariables': undefined,
  'unusedVariables': unused,
};

/// Pumps the General tab for a project, with [answer] as every check's answer,
/// and waits until the first check has landed.
Future<(Store<AppState>, _AnsweringAdapter)> _pump(
  WidgetTester tester, {
  required Map<String, Object?> answer,
  ExpressionModel? expression,
}) async {
  // A wide surface: the functions sidebar sits beside the editor.
  tester.view
    ..physicalSize = const Size(1400, 1600)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  final adapter = _AnsweringAdapter(answer);
  ApiService().expressionApi.apiClient.dio.httpClientAdapter = adapter;
  final store = Store<AppState>(
    initialState: AppState(
      selectedProject: _project,
      selectedExpression: expression ?? _expression(),
      expressionCatalog: _catalog,
    ),
  );
  await pumpInApp(tester, store, const ExpressionGeneralPage());
  await pumpUntil(
    tester,
    action: () async {},
    done: () => store.state.expressionValidation != null,
  );
  return (store, adapter);
}

void main() {
  testWidgets('an invalid check shows its message under the formula', (
    tester,
  ) async {
    await _pump(
      tester,
      answer: _answer(
        valid: false,
        errors: [
          {'message': 'Unexpected end of formula', 'start': 4, 'end': 9},
        ],
      ),
    );

    expect(find.text('Unexpected end of formula'), findsOneWidget);
    expect(find.byKey(const ValueKey('expression_valid')), findsNothing);
  });

  testWidgets('a valid check shows the valid mark', (tester) async {
    await _pump(tester, answer: _answer());

    expect(find.byKey(const ValueKey('expression_valid')), findsOneWidget);
  });

  testWidgets('an undefined variable is offered with the names it is missing', (
    tester,
  ) async {
    await _pump(tester, answer: _answer(undefined: ['b']));

    expect(find.text('Not declared: b'), findsOneWidget);
    expect(find.byKey(const ValueKey('expression_declare_b')), findsOneWidget);
    expect(find.byKey(const ValueKey('expression_declare_all')), findsNothing);
  });

  testWidgets(
    'declaring a name adds it as a number variable and marks unsaved',
    (tester) async {
      final (store, adapter) = await _pump(
        tester,
        answer: _answer(undefined: ['b']),
      );

      await tester.tap(find.byKey(const ValueKey('expression_declare_b')));
      await tester.pump();
      await pumpUntil(
        tester,
        action: () async {},
        done: () => adapter.asked.length >= 2,
      );

      final declared = store.state.selectedExpression!.variables.last;
      expect(declared.name, 'b');
      expect(declared.type, ExpressionVariableType.NUMBER);
      expect(store.state.unsavedChanges, NavigationEntry.expression);
    },
  );

  testWidgets('declare all adds every missing name', (tester) async {
    final (store, adapter) = await _pump(
      tester,
      answer: _answer(undefined: ['b', 'c']),
    );

    await tester.tap(find.byKey(const ValueKey('expression_declare_all')));
    await tester.pump();
    await pumpUntil(
      tester,
      action: () async {},
      done: () => adapter.asked.length >= 2,
    );

    expect(
      store.state.selectedExpression!.variables.map(
        (variable) => variable.name,
      ),
      ['radius', 'rate', 'b', 'c'],
    );
  });

  testWidgets('an unused variable chip shows the unused tooltip', (
    tester,
  ) async {
    await _pump(tester, answer: _answer(unused: ['rate']));

    expect(find.byTooltip('Not used in the formula'), findsOneWidget);
  });
}
