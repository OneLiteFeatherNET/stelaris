import 'package:async_redux/async_redux.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/expression/expression_preview.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/pump_until.dart';

const _double = ExpressionModel(
  uiName: 'Double',
  id: 'e1',
  projectId: 'p1',
  expression: 'a * 2',
  variables: [ExpressionVariable(name: 'a', testValue: '3')],
);

/// The value the backend gives each formula the tests use.
const _values = {'a * 2': '6', 'a * 4': '12'};

Store<AppState> _storeWith(ExpressionModel expression) =>
    Store<AppState>(initialState: AppState(selectedExpression: expression));

/// The expressions the backend was asked to evaluate, in order. Each test
/// has its own list, so no state is shared between tests.
Future<void> _useFakeBackend(
  WidgetTester tester,
  List<Map<String, dynamic>> sent, {
  int statusCode = 200,
  Object? error,
}) async {
  ApiService().expressionApi.apiClient.dio.httpClientAdapter =
      FakeHttpClientAdapter((options) {
        final data = options.data as Map<String, dynamic>;
        sent.add(data);
        if (error != null) {
          return FakeHttpClientAdapter.response(error, statusCode: statusCode);
        }
        final expression = data['expression'] as String;
        return FakeHttpClientAdapter.response({
          'value': _values[expression] ?? '0',
          'type': 'NUMBER',
        });
      });
}

/// Pumps the preview alone. No settle: the debounce timer is left for the
/// test to fire, so its timing is the test's own.
Future<void> _pumpPreview(WidgetTester tester, Store<AppState> store) async {
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: store,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ExpressionPreview()),
      ),
    ),
  );
  await tester.pump();
}

/// Fires the debounce timer and waits for the backend's answer to show.
Future<void> _settle(WidgetTester tester, {required String until}) async {
  await pumpUntil(
    tester,
    action: () => tester.pump(expressionPreviewDebounce),
    done: () => find.text(until).evaluate().isNotEmpty,
  );
}

void main() {
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('shows the formula in monospace with its variables', (
    tester,
  ) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(tester, sent);
    await _pumpPreview(tester, _storeWith(_double));

    await _settle(tester, until: '6');

    expect(find.text('a * 2'), findsOneWidget);
    expect(find.text('a'), findsOneWidget, reason: 'the variable name');
    expect(find.text('3'), findsOneWidget, reason: 'its test value');
  });

  testWidgets('shows the result with the type the backend gave as a chip', (
    tester,
  ) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(tester, sent);
    await _pumpPreview(tester, _storeWith(_double));

    await _settle(tester, until: '6');

    expect(
      find.widgetWithText(Chip, 'NUMBER'),
      findsOneWidget,
      reason: 'the type is shown as a chip',
    );
  });

  testWidgets('a rejected formula shows its violation in the error colour', (
    tester,
  ) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(
      tester,
      sent,
      statusCode: 400,
      error: {
        'title': 'Bad Request',
        'status': 400,
        'errors': [
          {'field': 'expression', 'message': 'Unknown function FOO'},
        ],
      },
    );
    await _pumpPreview(tester, _storeWith(_double));

    await _settle(tester, until: 'Unknown function FOO');

    final message = tester.widget<Text>(find.text('Unknown function FOO'));
    final colorScheme = Theme.of(
      tester.element(find.text('Unknown function FOO')),
    ).colorScheme;
    expect(
      message.style?.color,
      colorScheme.error,
      reason: 'a violation is shown in the error colour',
    );
  });

  testWidgets('a server error shows the generic message', (tester) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(
      tester,
      sent,
      statusCode: 500,
      error: {'title': 'Boom', 'status': 500},
    );
    await _pumpPreview(tester, _storeWith(_double));

    await _settle(tester, until: l10n.expression_test_error);

    expect(find.text(l10n.expression_test_error), findsOneWidget);
  });

  testWidgets(
    'a variable without a test value is not sent, the preview asks for one',
    (tester) async {
      final sent = <Map<String, dynamic>>[];
      await _useFakeBackend(tester, sent);
      await _pumpPreview(
        tester,
        _storeWith(
          const ExpressionModel(
            uiName: 'Sum',
            id: 'e2',
            projectId: 'p1',
            expression: 'a + b',
            variables: [
              ExpressionVariable(name: 'a', testValue: '3'),
              ExpressionVariable(name: 'b'),
            ],
          ),
        ),
      );

      await tester.pump(expressionPreviewDebounce);
      await tester.pump();

      expect(sent, isEmpty, reason: 'the backend is not asked');
      expect(
        find.text(l10n.expression_preview_missing_values('b')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'a burst of formula changes is asked for once, after the debounce',
    (tester) async {
      final sent = <Map<String, dynamic>>[];
      await _useFakeBackend(tester, sent);
      final store = _storeWith(_double);
      await _pumpPreview(tester, store);
      await _settle(tester, until: '6');
      expect(sent, hasLength(1), reason: 'the first formula is asked once');

      for (final formula in ['a * 3', 'a * 4']) {
        await tester.runAsync(
          () async => store.dispatch(
            UpdateExpressionAction(_double.copyWith(expression: formula)),
          ),
        );
        await tester.pump();
      }
      await tester.pump(
        expressionPreviewDebounce - const Duration(milliseconds: 1),
      );
      expect(
        sent,
        hasLength(1),
        reason: 'nothing is asked before the debounce has passed',
      );

      await tester.pump(const Duration(milliseconds: 1));
      await _settle(tester, until: '12');
      expect(sent, hasLength(2));
      expect(
        sent.last['expression'],
        'a * 4',
        reason: 'only the last formula of the burst is asked',
      );
    },
  );

  testWidgets('a valid formula is shown typeset as math', (tester) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(tester, sent);
    await _pumpPreview(tester, _storeWith(_double));

    await _settle(tester, until: '6');

    expect(
      find.byType(Math),
      findsWidgets,
      reason: 'the formula is typeset in the Formula section',
    );
  });

  testWidgets('an invalid formula is shown as its text, not as math', (
    tester,
  ) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(tester, sent);
    const broken = ExpressionModel(
      uiName: 'Broken',
      id: 'e2',
      projectId: 'p1',
      expression: 'a * (',
      variables: [ExpressionVariable(name: 'a', testValue: '3')],
    );
    await _pumpPreview(tester, _storeWith(broken));

    await _settle(tester, until: '0');

    expect(find.byType(Math), findsNothing);
    final text = tester.widget<Text>(find.text('a * ('));
    expect(
      text.style?.fontFamily,
      'monospace',
      reason: 'the formula that does not convert is shown in monospace',
    );
  });
}
