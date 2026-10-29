import 'dart:async';
import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/expression_validation_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

const Project _project = Project(id: 'p1', displayName: 'P1', key: 'p1');

ExpressionModel _expression(String text, {List<String> variables = const []}) =>
    ExpressionModel(
      uiName: 'Damage',
      id: 'e1',
      expression: text,
      variables: [for (final name in variables) ExpressionVariable(name: name)],
    );

Map<String, Object?> _answer({
  bool valid = true,
  List<String> undefined = const [],
}) => {
  'valid': valid,
  'errors': <Object>[],
  'usedVariables': <Object>[],
  'undefinedVariables': undefined,
  'unusedVariables': <Object>[],
};

/// An HTTP double that keeps every request open until the test answers it, so
/// the test decides when, and whether, each answer arrives.
class _HeldAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final List<Completer<ResponseBody>> _answers = [];
  final List<(int, Completer<void>)> _waiting = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    final answer = Completer<ResponseBody>();
    _answers.add(answer);
    _wake();
    return answer.future;
  }

  /// Completes once at least [count] requests have arrived.
  Future<void> untilRequested(int count) {
    final done = Completer<void>();
    _waiting.add((count, done));
    _wake();
    return done.future;
  }

  void _wake() {
    _waiting.removeWhere((waiter) {
      if (requests.length < waiter.$1) return false;
      waiter.$2.complete();
      return true;
    });
  }

  void answer(int index, Object json, {int statusCode = 200}) => _answers[index]
      .complete(FakeHttpClientAdapter.response(json, statusCode: statusCode));

  @override
  void close({bool force = false}) {}
}

/// The debounce as the app uses it, driven by [fakeAsync] so no test waits on
/// the wall clock.
const _debounce = Duration(milliseconds: 400);

void main() {
  late Store<AppState> store;
  late _HeldAdapter adapter;

  setUp(() {
    adapter = _HeldAdapter();
    ApiService().expressionApi.apiClient.dio.httpClientAdapter = adapter;
    store = Store<AppState>(
      initialState: AppState(
        selectedProject: _project,
        selectedExpression: _expression('a', variables: ['a']),
      ),
    );
  });

  /// A check of [expression] with no debounce, for the tests where the
  /// debounce is not what they check.
  ValidateExpressionAction check(String expression, [List<String>? names]) =>
      ValidateExpressionAction(
        expression,
        names ?? ['a'],
        debounceDelay: Duration.zero,
      );

  test('only the last of several quick dispatches asks the backend', () {
    fakeAsync((async) {
      store.dispatch(ValidateExpressionAction('a', ['a']));
      async.elapse(const Duration(milliseconds: 100));
      store.dispatch(ValidateExpressionAction('a ', ['a']));
      async.elapse(const Duration(milliseconds: 100));
      store.dispatch(ValidateExpressionAction('a', ['a']));
      async.elapse(_debounce);
      async.flushMicrotasks();

      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.data, {
        'expression': 'a',
        'variables': ['a'],
      });
    });
  });

  test('a dispatch still within the pause restarts it', () {
    fakeAsync((async) {
      store.dispatch(ValidateExpressionAction('a', ['a']));
      async.elapse(const Duration(milliseconds: 300));
      store.dispatch(ValidateExpressionAction('a', ['a']));
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      expect(adapter.requests, isEmpty);
    });
  });

  test(
    'the answer is kept with the text and variables it was asked for',
    () async {
      final done = store.dispatchAndWait(check('a'));
      await adapter.untilRequested(1);
      adapter.answer(0, _answer(undefined: ['b']));
      await done;

      final kept = store.state.expressionValidation!;
      expect(kept.expression, 'a');
      expect(kept.variables, ['a']);
      expect(kept.validation.undefinedVariables, ['b']);
    },
  );

  test('an answer for a text that changed while it was pending is dropped', () {
    fakeAsync((async) {
      store.dispatch(ValidateExpressionAction('a', ['a']));
      async.elapse(_debounce);
      async.flushMicrotasks();
      expect(adapter.requests, hasLength(1));

      store.dispatch(
        UpdateExpressionAction(_expression('ab', variables: ['a'])),
      );
      adapter.answer(0, _answer());
      async.flushMicrotasks();

      expect(store.state.expressionValidation, isNull);
    });
  });

  test('a failed request clears the check without a message', () async {
    const before = ExpressionValidationState(
      expression: 'a',
      variables: ['a'],
      validation: ExpressionValidation(valid: true),
    );
    store = Store<AppState>(
      initialState: store.state.copyWith(expressionValidation: before),
    );
    final done = store.dispatchAndWait(check('a'));
    await adapter.untilRequested(1);
    adapter.answer(0, const {'message': 'down'}, statusCode: 500);
    await done;

    expect(store.state.expressionValidation, isNull);
  });

  test('nothing is asked without a selected project', () async {
    store = Store<AppState>(
      initialState: AppState(
        selectedExpression: _expression('a', variables: ['a']),
      ),
    );
    await store.dispatchAndWait(check('a'));

    expect(adapter.requests, isEmpty);
    expect(store.state.expressionValidation, isNull);
  });

  test('selecting another expression forgets the check', () {
    store = Store<AppState>(
      initialState: AppState(
        selectedProject: _project,
        selectedExpression: _expression('a', variables: ['a']),
        expressionValidation: const ExpressionValidationState(
          expression: 'a',
          variables: ['a'],
          validation: ExpressionValidation(valid: true),
        ),
      ),
    );

    store.dispatch(SelectExpressionAction(_expression('x')));

    expect(store.state.expressionValidation, isNull);
  });
}
