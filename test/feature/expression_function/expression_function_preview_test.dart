import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/expression/expression_preview_panel.dart';
import 'package:stelaris/feature/expression_function/expression_function_preview.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/pump_until.dart';

const _double = ExpressionFunctionModel(
  uiName: 'Double',
  id: 'f1',
  projectId: 'p1',
  name: 'double_it',
  body: 'base * 2',
  parameters: [ExpressionVariable(name: 'base', testValue: '3')],
);

/// Answers each evaluation with twice the argument `base`, and keeps what was
/// sent in [sent].
void _useFakeBackend(
  List<Map<String, dynamic>> sent, {
  int statusCode = 200,
  Object? error,
}) {
  ApiService().expressionFunctionApi.apiClient.dio.httpClientAdapter =
      FakeHttpClientAdapter((options) {
        final data = options.data as Map<String, dynamic>;
        sent.add(data);
        if (error != null) {
          return FakeHttpClientAdapter.response(error, statusCode: statusCode);
        }
        final arguments = data['arguments'] as Map<String, dynamic>;
        final base = int.tryParse('${arguments['base']}') ?? 0;
        return FakeHttpClientAdapter.response({
          'value': '${base * 2}',
          'type': 'NUMBER',
        });
      });
}

/// Pumps the preview alone. No settle: the debounce timer is left for the
/// test to fire.
Future<Store<AppState>> _pumpPreview(
  WidgetTester tester,
  ExpressionFunctionModel function,
) async {
  final store = Store<AppState>(
    initialState: AppState(selectedExpressionFunction: function),
  );
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: store,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ExpressionFunctionPreview()),
      ),
    ),
  );
  await tester.pump();
  return store;
}

/// Fires the debounce timer and waits for [until] to show.
Future<void> _settle(WidgetTester tester, {required String until}) async {
  await pumpUntil(
    tester,
    action: () => tester.pump(expressionPreviewDebounce),
    done: () => find.text(until).evaluate().isNotEmpty,
  );
}

void main() {
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets("calls the function with its parameters' test values", (
    tester,
  ) async {
    final sent = <Map<String, dynamic>>[];
    _useFakeBackend(sent);
    await _pumpPreview(tester, _double);

    await _settle(tester, until: '6');

    expect(sent, hasLength(1));
    expect(sent.single['arguments'], {'base': '3'});
    expect(
      (sent.single['function'] as Map<String, dynamic>)['body'],
      'base * 2',
    );
    expect(find.text(l10n.expression_function_preview_parameters), findsOne);
    expect(find.text('base'), findsOneWidget, reason: 'the parameter name');
  });

  testWidgets('a value typed in is tried without being stored', (tester) async {
    final sent = <Map<String, dynamic>>[];
    _useFakeBackend(sent);
    final store = await _pumpPreview(tester, _double);
    await _settle(tester, until: '6');

    await tester.enterText(find.byType(TextField), '5');
    await _settle(tester, until: '10');

    expect(sent.last['arguments'], {'base': '5'});
    expect(find.text(l10n.expression_preview_value_not_saved), findsOne);
    expect(
      store.state.selectedExpressionFunction!.parameters.single.testValue,
      '3',
      reason: 'the stored test value stays',
    );

    await tester.tap(find.byKey(const Key('expression_preview_reset')));
    await _settle(tester, until: '6');
    expect(sent.last['arguments'], {'base': '3'});
  });

  testWidgets('a formula without a body asks for one and sends nothing', (
    tester,
  ) async {
    final sent = <Map<String, dynamic>>[];
    _useFakeBackend(sent);
    await _pumpPreview(tester, _double.copyWith(body: ''));
    await tester.pump(expressionPreviewDebounce);
    await tester.pump();

    expect(find.text(l10n.expression_function_preview_empty_hint), findsOne);
    expect(sent, isEmpty);
  });

  testWidgets('an interface without a stub points to the stub', (tester) async {
    final sent = <Map<String, dynamic>>[];
    _useFakeBackend(sent);
    await _pumpPreview(
      tester,
      _double.copyWith(kind: ExpressionFunctionKind.interface, body: null),
    );
    await tester.pump(expressionPreviewDebounce);
    await tester.pump();

    expect(
      find.text(l10n.expression_function_preview_interface_hint),
      findsOne,
    );
    expect(sent, isEmpty);
  });

  testWidgets('a parameter without a value is asked for, nothing is sent', (
    tester,
  ) async {
    final sent = <Map<String, dynamic>>[];
    _useFakeBackend(sent);
    await _pumpPreview(
      tester,
      _double.copyWith(parameters: const [ExpressionVariable(name: 'base')]),
    );
    await tester.pump(expressionPreviewDebounce);
    await tester.pump();

    expect(find.text(l10n.expression_preview_missing_values('base')), findsOne);
    expect(sent, isEmpty);
  });

  testWidgets('a function without parameters says so', (tester) async {
    final sent = <Map<String, dynamic>>[];
    _useFakeBackend(sent);
    await _pumpPreview(tester, _double.copyWith(body: '4', parameters: []));

    await _settle(tester, until: '0');

    expect(find.text(l10n.expression_function_preview_no_parameters), findsOne);
  });

  testWidgets('a rejected function shows the violation', (tester) async {
    final sent = <Map<String, dynamic>>[];
    _useFakeBackend(
      sent,
      statusCode: 400,
      error: {
        'title': 'Bad Request',
        'status': 400,
        'errors': [
          {'field': 'body', 'message': 'Unknown variable x'},
        ],
      },
    );
    await _pumpPreview(tester, _double);

    await _settle(tester, until: 'Unknown variable x');

    expect(find.text('Unknown variable x'), findsOneWidget);
  });
}
