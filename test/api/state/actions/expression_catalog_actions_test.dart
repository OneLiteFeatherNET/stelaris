import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/app_state.dart';

import '../../../support/fake_http_client_adapter.dart';

const _catalogJson = {
  'evalexVersion': '3.8.0',
  'functions': [
    {'name': 'ROUND', 'category': 'BASIC', 'parameters': []},
  ],
  'operators': [],
  'constants': [],
};

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

void main() {
  test('loading the catalog stores it in the state', () async {
    final store = Store<AppState>(initialState: const AppState());
    ApiService().expressionApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter.json(_catalogJson);

    await store.dispatchAndWait(LoadExpressionCatalogAction());

    expect(store.state.expressionCatalog?.functions.single.name, 'ROUND');
  });

  test('a second load makes no request once the catalog is loaded', () async {
    final store = Store<AppState>(initialState: const AppState());
    final adapter = _CountingAdapter(
      (_) => FakeHttpClientAdapter.response(_catalogJson),
    );
    ApiService().expressionApi.apiClient.dio.httpClientAdapter = adapter;

    await store.dispatchAndWait(LoadExpressionCatalogAction());
    await store.dispatchAndWait(LoadExpressionCatalogAction());

    expect(adapter.requests, 1);
    expect(store.state.expressionCatalog, isNotNull);
  });

  test('a failed load leaves the catalog null and does not throw', () async {
    final store = Store<AppState>(initialState: const AppState());
    ApiService().expressionApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter.json({'title': 'Boom'}, statusCode: 500);

    await store.dispatchAndWait(LoadExpressionCatalogAction());

    expect(store.state.expressionCatalog, isNull);
  });
}
