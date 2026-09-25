import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/actions/entity_search_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/command_palette/entity_search_source.dart';
import 'package:stelaris/feature/command_palette/entity_search_state.dart';
import 'package:stelaris/feature/command_palette/palette_mode.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// A search service whose answers the test hands out one by one.
class _FakeSource implements EntitySearchSource {
  final List<EntitySearchRequest> requests = [];
  final List<Completer<List<EntityHit>>> answers = [];

  @override
  Future<List<EntityHit>> search(EntitySearchRequest request) {
    requests.add(request);
    final answer = Completer<List<EntityHit>>();
    answers.add(answer);
    return answer.future;
  }
}

EntitySearchRequest _request(String query) =>
    EntitySearchRequest(query: query, limit: maxEntityResults);

const EntityHit _blade = EntityHit(
  EntityKind.item,
  ItemModel(uiName: 'Blade', id: 'b'),
);

/// Starts a search the way the app bar does: record it, then ask.
Future<ActionStatus> _ask(
  Store<AppState> store,
  _FakeSource source,
  EntitySearchRequest request,
) {
  store.dispatch(EntitySearchStartedAction(request));
  return store.dispatchAndWait(EntitySearchAction(source, request));
}

Future<void> _untilAsked(_FakeSource source, int count) async {
  while (source.requests.length < count) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  late Store<AppState> store;
  late _FakeSource source;

  setUp(() {
    store = Store<AppState>(initialState: const AppState());
    source = _FakeSource();
  });

  test('starting a search records it as pending', () {
    store.dispatch(EntitySearchStartedAction(_request('bl')));

    expect(store.state.entitySearch.request, _request('bl'));
    expect(store.state.entitySearch.status, EntitySearchStatus.pending);
  });

  test('the debounce keeps only the last dispatch', () async {
    store.dispatch(EntitySearchAction(source, _request('b')));
    store.dispatch(EntitySearchAction(source, _request('bl')));
    final done = _ask(store, source, _request('bla'));
    await _untilAsked(source, 1);
    source.answers.single.complete([_blade]);
    await done;

    expect(source.requests, [_request('bla')]);
    expect(store.state.entitySearch.hits, [_blade]);
    expect(store.state.entitySearch.status, EntitySearchStatus.done);
  });

  test(
    'an answer for a request that is no longer current is dropped',
    () async {
      final older = _ask(store, source, _request('bl'));
      await _untilAsked(source, 1);
      // A newer question arrives while the older one is waiting on the source.
      store.dispatch(EntitySearchStartedAction(_request('blade')));
      source.answers.single.complete([_blade]);
      await older;

      expect(store.state.entitySearch.request, _request('blade'));
      expect(store.state.entitySearch.hits, isEmpty);
      expect(store.state.entitySearch.status, EntitySearchStatus.pending);
    },
  );

  test('a failing source is recorded as failed', () async {
    final done = _ask(store, source, _request('bl'));
    await _untilAsked(source, 1);
    source.answers.single.completeError(Exception('down'));
    await done;

    expect(store.state.entitySearch.status, EntitySearchStatus.failed);
    expect(store.state.entitySearch.hits, isEmpty);
  });

  test('clearing forgets the search', () {
    store.dispatch(EntitySearchStartedAction(_request('bl')));
    store.dispatch(ClearEntitySearchAction());

    expect(store.state.entitySearch, const EntitySearchState());
  });
}
