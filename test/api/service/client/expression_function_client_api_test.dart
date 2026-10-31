import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/service/client/expression_function_client_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/recording_http_client_adapter.dart';

void main() {
  late ApiClient apiClient;
  late ExpressionFunctionClientApi functionApi;

  setUp(() {
    apiClient = ApiClient('http://backend.test/api');
    functionApi = ExpressionFunctionClientApi(apiClient: apiClient);
  });

  const base = ExpressionVariable(
    name: 'base',
    type: ExpressionValueType.number,
    testValue: '2',
  );

  const function = ExpressionFunctionModel(
    uiName: 'Damage bonus',
    name: 'damage_bonus',
    body: 'base * 2',
    parameters: [
      base,
      ExpressionVariable(name: 'crit', type: ExpressionValueType.boolean),
    ],
    projectId: 'p1',
  );

  test('the list GETs the functions of the project', () async {
    final adapter = RecordingHttpClientAdapter({
      'items': [],
      'totalItems': 0,
      'totalPages': 0,
      'currentPage': 0,
      'pageSize': 10,
    });
    apiClient.dio.httpClientAdapter = adapter;

    await functionApi.getPage(projectId: 'p1');

    expect(adapter.lastRequest!.method, 'GET');
    expect(
      adapter.lastRequest!.uri.path,
      '/api/project/p1/expression-function',
    );
  });

  test('add POSTs the function to the project', () async {
    final adapter = RecordingHttpClientAdapter({
      'id': 'f1',
      'uiName': 'Damage bonus',
      'name': 'damage_bonus',
    });
    apiClient.dio.httpClientAdapter = adapter;

    final created = await functionApi.add(function);

    expect(adapter.lastRequest!.method, 'POST');
    expect(
      adapter.lastRequest!.uri.path,
      '/api/project/p1/expression-function',
    );
    expect(created.id, 'f1');
  });

  test('update POSTs the function to its update path', () async {
    final adapter = RecordingHttpClientAdapter({
      'id': 'f1',
      'uiName': 'Damage bonus',
      'name': 'damage_bonus',
    });
    apiClient.dio.httpClientAdapter = adapter;

    await functionApi.update(function.copyWith(id: 'f1'));

    expect(adapter.lastRequest!.method, 'POST');
    expect(
      adapter.lastRequest!.uri.path,
      '/api/project/p1/expression-function/update',
    );
  });

  test('remove DELETEs the function by its id', () async {
    final adapter = RecordingHttpClientAdapter({
      'id': 'f1',
      'uiName': 'Damage bonus',
      'name': 'damage_bonus',
    });
    apiClient.dio.httpClientAdapter = adapter;

    await functionApi.remove(function.copyWith(id: 'f1'));

    expect(adapter.lastRequest!.method, 'DELETE');
    expect(
      adapter.lastRequest!.uri.path,
      '/api/project/p1/expression-function/delete/f1',
    );
  });

  test(
    'evaluate POSTs the function and its arguments to the project',
    () async {
      final adapter = RecordingHttpClientAdapter({
        'value': '4',
        'type': 'NUMBER',
      });
      apiClient.dio.httpClientAdapter = adapter;

      await functionApi.evaluate('p1', function);

      expect(adapter.lastRequest!.method, 'POST');
      expect(
        adapter.lastRequest!.uri.path,
        '/api/project/p1/expression-function/evaluate',
      );
      final data = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(data['arguments'], {'base': '2', 'crit': ''});
      expect(
        (data['function'] as Map<String, dynamic>)['name'],
        'damage_bonus',
      );
    },
  );

  test('evaluate returns the value and type the backend answered', () async {
    apiClient.dio.httpClientAdapter = FakeHttpClientAdapter.json({
      'value': 'true',
      'type': 'BOOLEAN',
    });

    final result = await functionApi.evaluate('p1', function);

    expect(result.value, 'true');
    expect(result.type, 'BOOLEAN');
  });

  test(
    'evaluate throws the problem with the field errors when rejected',
    () async {
      apiClient.dio.httpClientAdapter = FakeHttpClientAdapter.json({
        'title': 'Validation failed',
        'status': 400,
        'errors': [
          {
            'field': 'name',
            'message': 'Not a valid identifier',
            'code': 'FUNCTION_NAME_INVALID',
          },
        ],
      }, statusCode: 400);

      await expectLater(
        functionApi.evaluate('p1', function),
        throwsA(
          isA<ProblemDetail>().having(
            (problem) => problem.errors.single.field,
            'field',
            'name',
          ),
        ),
      );
    },
  );

  test('interface GETs the generated source of the project', () async {
    final adapter = RecordingHttpClientAdapter({
      'language': 'java',
      'typeName': 'ProjectFunctions',
      'source': 'public interface ProjectFunctions {}',
    });
    apiClient.dio.httpClientAdapter = adapter;

    final generated = await functionApi.interface('p1');

    expect(adapter.lastRequest!.method, 'GET');
    expect(
      adapter.lastRequest!.uri.path,
      '/api/project/p1/expression-function/interface',
    );
    expect(generated.source, 'public interface ProjectFunctions {}');
  });
}
