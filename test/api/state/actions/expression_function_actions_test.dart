import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/expression_function_model.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/actions/expression/expression_function_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

const Project project = Project(id: 'p1', displayName: 'P1', key: 'p1');

const _catalogJson = {
  'evalexVersion': '3.8.0',
  'functions': [
    {'name': 'damage_bonus', 'category': 'PROJECT', 'parameters': []},
  ],
};

/// Answers each request by the end of its path, and records the paths asked
/// for. A path with no answer gets a 404.
class _RoutingAdapter implements HttpClientAdapter {
  _RoutingAdapter(this.routes);

  /// The answer for each path ending, as a status code and a JSON body.
  final Map<String, (int, Object?)> routes;
  final List<String> paths = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add('${options.method} ${options.uri.path}');
    for (final entry in routes.entries) {
      if (options.uri.path.endsWith(entry.key)) {
        return FakeHttpClientAdapter.response(
          entry.value.$2,
          statusCode: entry.value.$1,
        );
      }
    }
    return FakeHttpClientAdapter.response({
      'title': 'Not found',
    }, statusCode: 404);
  }

  @override
  void close({bool force = false}) {}
}

const _functionJson = {
  'id': 'f1',
  'uiName': 'Damage bonus',
  'name': 'damage_bonus',
  'projectId': 'p1',
};

const _function = ExpressionFunctionModel(
  id: 'f1',
  uiName: 'Damage bonus',
  name: 'damage_bonus',
  projectId: 'p1',
);

Map<String, Object?> _page(List<Map<String, Object?>> items) => {
  'items': items,
  'totalItems': items.length,
  'totalPages': 1,
  'currentPage': 1,
  'pageSize': 10,
};

void main() {
  test(
    'InitExpressionFunctionAction loads the first page of the open project',
    () async {
      final store = Store<AppState>(
        initialState: const AppState(selectedProject: project),
      );
      ApiService().expressionFunctionApi.apiClient.dio.httpClientAdapter =
          _RoutingAdapter({
            'expression-function': (200, _page([_functionJson])),
          });

      await store.dispatchAndWait(InitExpressionFunctionAction());

      expect(store.state.expressionFunctions.items.map((f) => f.id), ['f1']);
      expect(store.state.isLoadingMoreExpressionFunctions, isFalse);
    },
  );

  test('SelectExpressionFunctionAction selects the function and drops an earlier rejection', () async {
    final store = Store<AppState>(
      initialState: const AppState(
        expressionFunctionProblem: ProblemDetail(title: 'Old', status: 400),
      ),
    );

    await store.dispatchAndWait(SelectExpressionFunctionAction(_function));

    expect(store.state.selectedExpressionFunction, _function);
    expect(store.state.expressionFunctionProblem, isNull);
  });

  test(
    'UpdateExpressionFunctionAction stages the function as unsaved',
    () async {
      final store = Store<AppState>(
        initialState: const AppState(selectedExpressionFunction: _function),
      );
      final changed = _function.copyWith(name: 'damage');

      await store.dispatchAndWait(UpdateExpressionFunctionAction(changed));

      expect(store.state.selectedExpressionFunction, changed);
      expect(store.state.unsavedChanges, NavigationEntry.function);
    },
  );

  test(
    'saving the function stores the saved copy and clears the unsaved flag',
    () async {
      final store = Store<AppState>(
        initialState: const AppState(
          selectedProject: project,
          selectedExpressionFunction: _function,
          unsavedChanges: NavigationEntry.function,
        ),
      );
      ApiService().expressionFunctionApi.apiClient.dio.httpClientAdapter =
          _RoutingAdapter({
            'expression-function/update': (200, _functionJson),
            'expression-catalog': (200, _catalogJson),
          });

      await store.dispatchAndWait(ExpressionFunctionDatabaseUpdate());

      expect(store.state.selectedExpressionFunction?.id, 'f1');
      expect(store.state.unsavedChanges, isNull);
    },
  );

  test('saving the function reloads the catalog, which holds the project functions', () async {
    final store = Store<AppState>(
      initialState: const AppState(
        selectedProject: project,
        selectedExpressionFunction: _function,
        unsavedChanges: NavigationEntry.function,
      ),
    );
    final adapter = _RoutingAdapter({
      'expression-function/update': (200, _functionJson),
      'expression-catalog': (200, _catalogJson),
    });
    ApiService().expressionFunctionApi.apiClient.dio.httpClientAdapter =
        adapter;

    await store.dispatchAndWait(ExpressionFunctionDatabaseUpdate());

    expect(adapter.paths, contains('GET /project/p1/expression-catalog'));
    expect(
      store.state.expressionCatalog?.functions.single.name,
      'damage_bonus',
    );
  });

  test('a rejected save keeps the backend violations in the state', () async {
    final store = Store<AppState>(
      initialState: const AppState(
        selectedProject: project,
        selectedExpressionFunction: _function,
        unsavedChanges: NavigationEntry.function,
      ),
    );
    ApiService().expressionFunctionApi.apiClient.dio.httpClientAdapter =
        _RoutingAdapter({
          'expression-function/update': (
            400,
            {
              'title': 'Validation failed',
              'status': 400,
              'errors': [
                {
                  'field': 'name',
                  'message': 'Name is taken',
                  'code': 'FUNCTION_NAME_TAKEN',
                },
              ],
            },
          ),
        });

    await expectLater(
      store.dispatchAndWait(ExpressionFunctionDatabaseUpdate()),
      throwsA(isA<ProblemDetail>()),
    );

    expect(
      store.state.expressionFunctionProblem?.errors.single.message,
      'Name is taken',
    );
    expect(store.state.unsavedChanges, NavigationEntry.function);
  });

  test('staging a change after a rejection drops the rejection', () async {
    final store = Store<AppState>(
      initialState: const AppState(
        selectedExpressionFunction: _function,
        expressionFunctionProblem: ProblemDetail(
          title: 'Validation failed',
          status: 400,
        ),
      ),
    );

    await store.dispatchAndWait(
      UpdateExpressionFunctionAction(_function.copyWith(name: 'x')),
    );

    expect(store.state.expressionFunctionProblem, isNull);
  });
}
