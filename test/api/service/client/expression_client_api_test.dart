import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/service/client/expression_client_api.dart';

import '../../../support/recording_http_client_adapter.dart';

void main() {
  late ApiClient apiClient;
  late ExpressionClientApi expressionApi;

  setUp(() {
    apiClient = ApiClient('http://backend.test/api');
    expressionApi = ExpressionClientApi(apiClient: apiClient);
  });

  const area = ExpressionVariable(
    name: 'radius',
    type: ExpressionVariableType.NUMBER,
    testValue: '2',
  );

  test(
    'evaluate POSTs the expression and its variables to the project',
    () async {
      final adapter = RecordingHttpClientAdapter({
        'value': '12.5',
        'type': 'NUMBER',
      });
      apiClient.dio.httpClientAdapter = adapter;

      await expressionApi.evaluate('p1', 'PI * radius ^ 2', [area]);

      expect(adapter.lastRequest!.method, 'POST');
      expect(
        adapter.lastRequest!.uri.path,
        '/api/project/p1/expression/evaluate',
      );
      expect(adapter.lastRequest!.data, {
        'expression': 'PI * radius ^ 2',
        'variables': {'radius': '2'},
        'types': {'radius': 'NUMBER'},
      });
    },
  );

  test('evaluate returns the value and type the backend answered', () async {
    apiClient.dio.httpClientAdapter = RecordingHttpClientAdapter({
      'value': 'true',
      'type': 'BOOLEAN',
    });

    final result = await expressionApi.evaluate('p1', 'a > 1', const []);

    expect(result.value, 'true');
    expect(result.type, 'BOOLEAN');
  });

  test(
    'evaluate sends a variable without a test value as an empty string',
    () async {
      final adapter = RecordingHttpClientAdapter({
        'value': '0',
        'type': 'NUMBER',
      });
      apiClient.dio.httpClientAdapter = adapter;

      await expressionApi.evaluate('p1', 'x', const [
        ExpressionVariable(name: 'x'),
      ]);

      expect(adapter.lastRequest!.data, {
        'expression': 'x',
        'variables': {'x': ''},
        'types': {'x': 'NUMBER'},
      });
    },
  );

  test('evaluate sends each variable type by its backend name', () async {
    final adapter = RecordingHttpClientAdapter({
      'value': 'x',
      'type': 'STRING',
    });
    apiClient.dio.httpClientAdapter = adapter;

    await expressionApi.evaluate('p1', 'label', const [
      ExpressionVariable(
        name: 'label',
        type: ExpressionVariableType.STRING,
        testValue: 'x',
      ),
    ]);

    expect((adapter.lastRequest!.data as Map)['types'], {'label': 'STRING'});
  });

  test(
    'evaluate reports a rejected expression as a problem with its field',
    () async {
      apiClient.dio.httpClientAdapter = RecordingHttpClientAdapter({
        'title': 'Validation failed',
        'status': 400,
        'code': 'VALIDATION_FAILED',
        'errors': [
          {
            'field': 'expression',
            'code': 'SYNTAX',
            'message': 'unexpected token',
          },
          {
            'field': 'variables.radius',
            'code': 'NOT_A_NUMBER',
            'message': 'must be a number',
          },
        ],
      }, statusCode: 400);

      final error = await expressionApi
          .evaluate('p1', '1 +', [area])
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(error, isA<ProblemDetail>());
      final problem = error as ProblemDetail;
      expect(problem.code, 'VALIDATION_FAILED');
      expect(problem.errors.map((e) => e.field), [
        'expression',
        'variables.radius',
      ]);
      expect(problem.errors.last.message, 'must be a number');
    },
  );

  test('evaluate lets any other failure through unchanged', () async {
    apiClient.dio.httpClientAdapter = RecordingHttpClientAdapter({
      'title': 'Boom',
      'status': 500,
    }, statusCode: 500);

    await expectLater(
      expressionApi.evaluate('p1', '1', const []),
      throwsA(isA<DioException>()),
    );
  });

  test('add POSTs a new expression to its project', () async {
    final adapter = RecordingHttpClientAdapter({
      'id': 'e1',
      'uiName': 'Damage',
      'projectId': 'p1',
    });
    apiClient.dio.httpClientAdapter = adapter;

    final created = await expressionApi.add(
      const ExpressionModel(uiName: 'Damage', projectId: 'p1'),
    );

    expect(adapter.lastRequest!.method, 'POST');
    expect(adapter.lastRequest!.uri.path, '/api/project/p1/expression');
    expect(created.id, 'e1');
  });

  test('catalog GETs the catalog under the base URL, not a project', () async {
    final adapter = RecordingHttpClientAdapter({
      'evalexVersion': '3.8.0',
      'functions': [
        {'name': 'ROUND', 'category': 'BASIC', 'parameters': []},
      ],
    });
    apiClient.dio.httpClientAdapter = adapter;

    final catalog = await expressionApi.catalog();

    expect(adapter.lastRequest!.method, 'GET');
    expect(adapter.lastRequest!.uri.path, '/api/expression/catalog');
    expect(catalog.functions.single.name, 'ROUND');
  });

  test(
    'validate POSTs the expression and the declared names to the project',
    () async {
      final adapter = RecordingHttpClientAdapter({
        'valid': true,
        'errors': <Object>[],
        'usedVariables': <Object>[],
        'undefinedVariables': <Object>[],
        'unusedVariables': <Object>[],
      });
      apiClient.dio.httpClientAdapter = adapter;

      await expressionApi.validate('p1', 'radius * 2', ['radius', 'height']);

      expect(adapter.lastRequest!.method, 'POST');
      expect(
        adapter.lastRequest!.uri.path,
        '/api/project/p1/expression/validate',
      );
      expect(adapter.lastRequest!.data, {
        'expression': 'radius * 2',
        'variables': ['radius', 'height'],
      });
    },
  );

  test('validate parses every field of the answer', () async {
    apiClient.dio.httpClientAdapter = RecordingHttpClientAdapter({
      'valid': false,
      'errors': [
        {'message': 'Unexpected end of formula', 'start': 4, 'end': 9},
      ],
      'usedVariables': ['radius'],
      'undefinedVariables': ['b'],
      'unusedVariables': ['height'],
    });

    final validation = await expressionApi.validate('p1', 'x * (', ['height']);

    expect(validation.valid, isFalse);
    expect(validation.errors.single.message, 'Unexpected end of formula');
    expect(validation.errors.single.start, 4);
    expect(validation.errors.single.end, 9);
    expect(validation.usedVariables, ['radius']);
    expect(validation.undefinedVariables, ['b']);
    expect(validation.unusedVariables, ['height']);
  });
}
