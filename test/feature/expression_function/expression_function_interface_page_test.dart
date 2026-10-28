import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/expression_function/expression_function_interface_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/pump_in_app.dart';

const _project = Project(id: 'p1', displayName: 'P1', key: 'p1');

const _source =
    'public interface ProjectFunctions {\n'
    '  double damageBonus(double base);\n'
    '}';

/// Counts the requests it receives and answers each with [respond].
class _CountingAdapter implements HttpClientAdapter {
  _CountingAdapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  int requests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests++;
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

Future<void> _pump(WidgetTester tester, ExpressionFunctionKind kind) async {
  final store = Store<AppState>(
    initialState: AppState(
      selectedProject: _project,
      selectedExpressionFunction: ExpressionFunctionModel(
        id: 'f1',
        uiName: 'Hit',
        name: 'hit',
        kind: kind,
        projectId: 'p1',
      ),
    ),
  );
  await pumpInApp(tester, store, const ExpressionFunctionInterfacePage());
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('an interface shows the generated source', (tester) async {
    ApiService().expressionFunctionApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter.json({
          'language': 'java',
          'typeName': 'ProjectFunctions',
          'source': _source,
        });

    await _pump(tester, ExpressionFunctionKind.INTERFACE);

    expect(
      tester.widget<SelectableText>(find.byType(SelectableText)).data,
      _source,
    );
  });

  testWidgets('a formula shows the empty state and requests no source', (
    tester,
  ) async {
    final adapter = _CountingAdapter(
      (_) => FakeHttpClientAdapter.response({
        'language': 'java',
        'typeName': 'ProjectFunctions',
        'source': _source,
      }),
    );
    ApiService().expressionFunctionApi.apiClient.dio.httpClientAdapter =
        adapter;

    await _pump(tester, ExpressionFunctionKind.FORMULA);

    expect(
      find.text(l10n.expression_function_interface_formula_header),
      findsOneWidget,
    );
    expect(adapter.requests, 0);
  });
}
