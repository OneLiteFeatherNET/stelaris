import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

const Project project = Project(id: 'p1', displayName: 'P1', key: 'p1');

PaginatedResult<ExpressionModel> _list(
  List<ExpressionModel> items, {
  int totalPages = 1,
  int currentPage = 1,
  int pageSize = 10,
}) => PaginatedResult<ExpressionModel>(
  items: items,
  totalItems: items.length,
  totalPages: totalPages,
  currentPage: currentPage,
  pageSize: pageSize,
);

Map<String, Object?> _page(
  List<Map<String, Object?>> items, {
  required int currentPage,
  required int totalPages,
}) => {
  'items': items,
  'totalItems': items.length,
  'totalPages': totalPages,
  'currentPage': currentPage,
  'pageSize': 1,
};

void _respond(Object json) {
  ApiService().expressionApi.apiClient.dio.httpClientAdapter =
      FakeHttpClientAdapter.json(json);
}

void main() {
  test(
    'InitExpressionAction loads the first page of the open project',
    () async {
      final store = Store<AppState>(
        initialState: const AppState(selectedProject: project),
      );
      _respond(
        _page(
          [
            {'id': 'e1', 'uiName': 'Damage'},
          ],
          currentPage: 1,
          totalPages: 1,
        ),
      );

      await store.dispatchAndWait(InitExpressionAction());

      expect(store.state.expressions.items.map((e) => e.id), ['e1']);
      expect(store.state.isLoadingMoreExpressions, isFalse);
    },
  );

  test(
    'InitExpressionAction loads the next page after the loaded ones',
    () async {
      final store = Store<AppState>(
        initialState: AppState(
          selectedProject: project,
          expressions: _list(
            [const ExpressionModel(uiName: 'Damage', id: 'e1')],
            totalPages: 2,
            pageSize: 1,
          ),
        ),
      );
      _respond(
        _page(
          [
            {'id': 'e2', 'uiName': 'Healing'},
          ],
          currentPage: 2,
          totalPages: 2,
        ),
      );

      await store.dispatchAndWait(InitExpressionAction());

      expect(store.state.expressions.items.map((e) => e.id), ['e1', 'e2']);
      expect(store.state.isLoadingMoreExpressions, isFalse);
    },
  );

  test('ExpressionAddAction adds the new expression to the open project and selects it', () async {
    final store = Store<AppState>(
      initialState: const AppState(selectedProject: project),
    );
    Object? postedProjectId;
    ApiService().expressionApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter((options) {
          postedProjectId = (options.data as Map<String, dynamic>)['projectId'];
          return FakeHttpClientAdapter.response({
            'id': 'e3',
            'uiName': 'Damage',
            'projectId': 'p1',
          });
        });

    await store.dispatchAndWait(
      ExpressionAddAction(
        const ExpressionModel(uiName: 'Damage', expression: ''),
      ),
    );

    expect(postedProjectId, 'p1');
    expect(store.state.expressions.items.map((e) => e.id), ['e3']);
    expect(store.state.selectedExpression?.id, 'e3');
  });

  test(
    'ExpressionDatabaseUpdate saves the selection and replaces its list entry',
    () async {
      const listed = ExpressionModel(
        uiName: 'Damage',
        id: 'e1',
        expression: '1',
      );
      final store = Store<AppState>(
        initialState: AppState(
          expressions: _list([listed]),
          selectedExpression: listed.copyWith(expression: 'base * 2'),
          unsavedChanges: NavigationEntry.expression,
        ),
      );
      _respond({
        'id': 'e1',
        'uiName': 'Damage',
        'expression': 'base * 2',
        'variables': [
          {'name': 'base', 'type': 'NUMBER', 'testValue': '4'},
        ],
      });

      await store.dispatchAndWait(ExpressionDatabaseUpdate());

      final saved = store.state.expressions.items.single;
      expect(saved.expression, 'base * 2');
      expect(saved.variables.single.name, 'base');
      expect(store.state.selectedExpression, saved);
      expect(store.state.unsavedChanges, isNull);
    },
  );

  test('ExpressionRemoveAction removes the entry and keeps the selection for the exit transition', () async {
    const existing = ExpressionModel(uiName: 'Damage', id: 'e1');
    final store = Store<AppState>(
      initialState: AppState(
        expressions: _list([
          existing,
          const ExpressionModel(uiName: 'Healing', id: 'e2'),
        ]),
        selectedExpression: existing,
      ),
    );
    _respond({'id': 'e1', 'uiName': 'Damage'});

    await store.dispatchAndWait(ExpressionRemoveAction(existing));

    expect(store.state.expressions.items.map((e) => e.id), ['e2']);
    expect(store.state.selectedExpression, existing);
  });

  test('ExpressionNotesUpdateAction saves the notes and only patches them into a selection of the same expression', () async {
    const listed = ExpressionModel(uiName: 'Damage', id: 'e1');
    // The selection carries an unsaved rename that must survive.
    final store = Store<AppState>(
      initialState: AppState(
        expressions: _list([listed]),
        selectedExpression: listed.copyWith(uiName: 'Renamed', comment: 'Old'),
      ),
    );
    _respond({'id': 'e1', 'uiName': 'Damage', 'comment': 'Boss room'});

    await store.dispatchAndWait(
      ExpressionNotesUpdateAction(listed, 'Boss room'),
    );

    expect(store.state.expressions.items.single.comment, 'Boss room');
    expect(store.state.selectedExpression!.uiName, 'Renamed');
    expect(store.state.selectedExpression!.comment, 'Boss room');
  });
}
