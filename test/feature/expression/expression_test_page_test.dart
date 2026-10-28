import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/expression/expression_test_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/pump_in_app.dart';
import '../../support/pump_until.dart';

Store<AppState> _storeWith(ExpressionModel expression) =>
    Store<AppState>(initialState: AppState(selectedExpression: expression));

const _double = ExpressionModel(
  uiName: 'Double',
  id: 'e1',
  projectId: 'p1',
  expression: 'a * 2',
  variables: [ExpressionVariable(name: 'a', testValue: '2')],
);

/// Answers the next evaluation with [json] and [statusCode].
void _respond(Object json, {int statusCode = 200}) {
  ApiService().expressionApi.apiClient.dio.httpClientAdapter =
      FakeHttpClientAdapter.json(json, statusCode: statusCode);
}

Future<void> _evaluate(WidgetTester tester, {required String until}) async {
  await pumpUntil(
    tester,
    action: () => tester.tap(find.text('Evaluate')),
    done: () => find.text(until).evaluate().isNotEmpty,
  );
}

void main() {
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('evaluate shows the value and the type the backend gave', (
    tester,
  ) async {
    final store = _storeWith(_double);
    await pumpInApp(tester, store, const ExpressionTestPage());
    _respond({'value': '4', 'type': 'NUMBER'});

    await _evaluate(tester, until: '4');

    expect(
      find.text(l10n.expression_test_result_type('NUMBER')),
      findsOneWidget,
    );
  });

  testWidgets('a rejected expression shows its violation message inline', (
    tester,
  ) async {
    final store = _storeWith(_double);
    await pumpInApp(tester, store, const ExpressionTestPage());
    _respond({
      'title': 'Bad Request',
      'status': 400,
      'errors': [
        {'field': 'expression', 'message': 'Unknown function FOO'},
      ],
    }, statusCode: 400);

    await _evaluate(tester, until: 'Unknown function FOO');

    expect(find.text('expression'), findsOneWidget);
    expect(find.text(l10n.expression_test_rejected), findsOneWidget);
  });

  testWidgets('a server error shows the generic message', (tester) async {
    final store = _storeWith(_double);
    await pumpInApp(tester, store, const ExpressionTestPage());
    _respond({'title': 'Boom', 'status': 500}, statusCode: 500);

    await _evaluate(tester, until: l10n.expression_test_error);

    expect(find.text(l10n.expression_test_error), findsOneWidget);
  });

  testWidgets('evaluate is disabled for an empty expression', (tester) async {
    final store = _storeWith(
      const ExpressionModel(uiName: 'Empty', id: 'e2', projectId: 'p1'),
    );
    await pumpInApp(tester, store, const ExpressionTestPage());

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(find.text(l10n.expression_test_empty_hint), findsOneWidget);
  });

  testWidgets(
    'the request carries the entered values and stores none of them',
    (tester) async {
      final store = _storeWith(_double);
      await pumpInApp(tester, store, const ExpressionTestPage());
      await tester.enterText(find.byKey(const ValueKey('a')), '7');
      Object? sent;
      ApiService().expressionApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            sent = options.data;
            return FakeHttpClientAdapter.response({
              'value': '14',
              'type': 'NUMBER',
            });
          });

      await _evaluate(tester, until: '14');

      expect((sent! as Map<String, dynamic>)['variables'], {'a': '7'});
      expect(store.state.selectedExpression?.variables.single.testValue, '2');
      expect((sent as Map<String, dynamic>)['expression'], 'a * 2');
    },
  );
}
