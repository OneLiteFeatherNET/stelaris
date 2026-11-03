import 'dart:async';
import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/expression/expression_preview.dart';
import 'package:stelaris/feature/expression/expression_preview_panel.dart';
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
Future<void> _pumpPreview(
  WidgetTester tester,
  Store<AppState> store, {
  bool showFormula = true,
}) async {
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ExpressionPreview(showFormula: showFormula)),
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

  testWidgets('lists the variables with their test values', (tester) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(tester, sent);
    await _pumpPreview(tester, _storeWith(_double));

    await _settle(tester, until: '6');

    expect(find.text('a'), findsOneWidget, reason: 'the variable name');
    expect(find.text('3'), findsOneWidget, reason: 'its test value');
  });

  testWidgets('shows the result with its type in words', (tester) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(tester, sent);
    await _pumpPreview(tester, _storeWith(_double));

    await _settle(tester, until: '6');

    expect(find.text(l10n.expression_variable_type_number), findsOneWidget);
    expect(find.text('NUMBER'), findsNothing);
  });

  testWidgets('the result comes before the formula and the variables', (
    tester,
  ) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(tester, sent);
    await _pumpPreview(tester, _storeWith(_double));

    await _settle(tester, until: '6');

    final resultY = tester.getTopLeft(find.text('6')).dy;
    expect(
      resultY,
      lessThan(
        tester.getTopLeft(find.text(l10n.expression_section_formula)).dy,
      ),
    );
    expect(resultY, lessThan(tester.getTopLeft(find.text('a')).dy));
  });

  testWidgets('without showFormula the formula is left out', (tester) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(tester, sent);
    await _pumpPreview(tester, _storeWith(_double), showFormula: false);

    await _settle(tester, until: '6');

    expect(find.text(l10n.expression_section_formula), findsNothing);
    expect(find.text('a'), findsOneWidget, reason: 'the variables stay');
  });

  testWidgets('the last result stays, dimmed, while the next is asked for', (
    tester,
  ) async {
    final adapter = _HeldAdapter();
    ApiService().expressionApi.apiClient.dio.httpClientAdapter = adapter;
    final store = _storeWith(_double);
    await _pumpPreview(tester, store);
    await _settle(tester, until: '6');
    final result = find.byKey(const ValueKey('expression_preview_result'));
    double opacity() => tester.widget<AnimatedOpacity>(result).opacity;
    expect(opacity(), 1);

    await tester.runAsync(
      () async => store.dispatch(
        UpdateExpressionAction(_double.copyWith(expression: 'a * 4')),
      ),
    );
    await tester.pump();
    await tester.pump(expressionPreviewDebounce);
    await tester.pump();

    expect(find.text('6'), findsOneWidget, reason: 'no spinner in its place');
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(opacity(), lessThan(1));

    adapter.release();
    await _settle(tester, until: '12');
    await tester.pumpAndSettle();
    expect(opacity(), 1);
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

    await _settle(tester, until: l10n.expression_preview_error);

    expect(find.text(l10n.expression_preview_error), findsOneWidget);
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

  testWidgets('a value typed in is evaluated with, and marked as not saved', (
    tester,
  ) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(tester, sent);
    final store = _storeWith(_double);
    await _pumpPreview(tester, store);
    await _settle(tester, until: '6');

    await tester.enterText(find.byType(TextField), '5');
    await tester.pump();
    expect(find.text(l10n.expression_preview_value_not_saved), findsOneWidget);
    await pumpUntil(
      tester,
      action: () => tester.pump(expressionPreviewDebounce),
      done: () => sent.length == 2,
    );

    expect(sent, hasLength(2));
    expect((sent.last['variables'] as Map)['a'], '5');
    expect(
      store.state.selectedExpression?.variables.single.testValue,
      '3',
      reason: 'the stored test value stays',
    );
  });

  testWidgets('reset brings back the stored test values', (tester) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(tester, sent);
    await _pumpPreview(tester, _storeWith(_double));
    await _settle(tester, until: '6');
    final reset = find.byKey(const Key('expression_preview_reset'));
    expect(reset, findsNothing, reason: 'nothing to reset yet');

    await tester.enterText(find.byType(TextField), '5');
    await tester.pump();
    await tester.tap(reset);
    await tester.pump();

    expect(find.text('3'), findsOneWidget);
    expect(find.text(l10n.expression_preview_value_not_saved), findsNothing);
    expect(reset, findsNothing);
    await tester.pump(expressionPreviewDebounce);
  });

  testWidgets('typing the stored value again is no override', (tester) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(tester, sent);
    await _pumpPreview(tester, _storeWith(_double));
    await _settle(tester, until: '6');

    await tester.enterText(find.byType(TextField), '5');
    await tester.pump();
    await tester.enterText(find.byType(TextField), '3');
    await tester.pump();

    expect(find.text(l10n.expression_preview_value_not_saved), findsNothing);
    expect(find.byKey(const Key('expression_preview_reset')), findsNothing);
    await tester.pump(expressionPreviewDebounce);
  });

  testWidgets('a missing value typed in lets the preview evaluate', (
    tester,
  ) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(tester, sent);
    await _pumpPreview(
      tester,
      _storeWith(
        const ExpressionModel(
          uiName: 'Double',
          id: 'e2',
          projectId: 'p1',
          expression: 'a * 2',
          variables: [ExpressionVariable(name: 'a')],
        ),
      ),
    );
    await tester.pump(expressionPreviewDebounce);
    expect(sent, isEmpty);

    await tester.enterText(find.byType(TextField), '3');
    await tester.pump();
    await _settle(tester, until: '6');

    expect(sent, hasLength(1));
  });

  testWidgets('a stored test value changed elsewhere shows in its input', (
    tester,
  ) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(tester, sent);
    final store = _storeWith(_double);
    await _pumpPreview(tester, store);
    await _settle(tester, until: '6');

    await tester.runAsync(
      () async => store.dispatch(
        UpdateExpressionAction(
          _double.copyWith(
            variables: const [ExpressionVariable(name: 'a', testValue: '7')],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('7'), findsOneWidget);
    expect(find.text(l10n.expression_preview_value_not_saved), findsNothing);
    await tester.pump(expressionPreviewDebounce);
  });

  testWidgets('a value typed for a renamed variable is left out', (
    tester,
  ) async {
    final sent = <Map<String, dynamic>>[];
    await _useFakeBackend(tester, sent);
    final store = _storeWith(_double);
    await _pumpPreview(tester, store);
    await _settle(tester, until: '6');
    await tester.enterText(find.byType(TextField), '5');
    await tester.pump();

    await tester.runAsync(
      () async => store.dispatch(
        UpdateExpressionAction(
          _double.copyWith(
            expression: 'b * 2',
            variables: const [ExpressionVariable(name: 'b', testValue: '3')],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('3'), findsOneWidget, reason: 'its stored test value');
    expect(find.byKey(const Key('expression_preview_reset')), findsNothing);
    await tester.pump(expressionPreviewDebounce);
  });

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

  group('formatExpressionResult', () {
    test('rounds a long decimal to six places', () {
      expect(formatExpressionResult('6.66666666666666666667'), '6.666667');
    });

    test('drops the zeros rounding leaves at the end', () {
      expect(formatExpressionResult('2.50000000001'), '2.5');
      expect(formatExpressionResult('3.0000000001'), '3');
    });

    test('keeps a short number, a word and a boolean as they are', () {
      expect(formatExpressionResult('6.25'), '6.25');
      expect(formatExpressionResult('12'), '12');
      expect(formatExpressionResult('true'), 'true');
      expect(formatExpressionResult('hello.world'), 'hello.world');
    });
  });
}

/// Answers the first evaluation at once and holds every later one until
/// [release], so a test can look at the preview while it waits.
class _HeldAdapter implements HttpClientAdapter {
  final Completer<void> _gate = Completer<void>();
  int _requests = 0;

  void release() => _gate.complete();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_requests++ > 0) await _gate.future;
    final expression = (options.data as Map<String, dynamic>)['expression'];
    return FakeHttpClientAdapter.response({
      'value': _values[expression] ?? '0',
      'type': 'NUMBER',
    });
  }

  @override
  void close({bool force = false}) {}
}
