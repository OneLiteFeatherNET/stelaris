import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/state/actions/block_state_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/list_actions.dart';

/// Answers every request of the blockstate API with [json].
void _respond(Object json) {
  (ApiService().blockStateApi as BaseApi<BlockStateModel>)
      .apiClient
      .dio
      .httpClientAdapter = FakeHttpClientAdapter.json(
    json,
  );
}

Store<AppState> _storeWith({
  required List<BlockStateModel> items,
  BlockStateModel? selected,
}) => Store<AppState>(
  initialState: const AppState().copyWith(
    selectedBlockState: selected,
    blockStates: PaginatedResult<BlockStateModel>(
      items: items,
      totalItems: items.length,
      totalPages: 1,
      currentPage: 1,
      pageSize: 10,
    ),
  ),
);

void main() {
  listActionTests<BlockStateModel>(
    model: (id, {projectId}) =>
        BlockStateModel(uiName: id, id: id, projectId: projectId),
    listOf: (state) => state.blockStates,
    withList: (state, list) => state.copyWith(blockStates: list),
    isLoadingMore: (store) => store.state.isLoadingMoreBlockStates,
    selectedOf: (state) => state.selectedBlockState,
    withSelected: (state, model) => state.copyWith(selectedBlockState: model),
    init: InitBlockStateAction.new,
    refresh: RefreshBlockStateAction.new,
    add: BlockStateAddAction.new,
    remove: BlockStateRemoveAction.new,
  );

  group('LoadAllBlockStatesAction', () {
    test('loads the pages the list is still missing', () async {
      const loaded = BlockStateModel(id: 'b1', uiName: 'Seats');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          blockStates: const PaginatedResult<BlockStateModel>(
            items: [loaded],
            totalItems: 2,
            totalPages: 2,
            currentPage: 1,
            pageSize: 1,
          ),
        ),
      );
      _respond({
        'items': [
          {'id': 'b2', 'uiName': 'Roof'},
        ],
        'totalItems': 2,
        'totalPages': 2,
        'currentPage': 2,
        'pageSize': 1,
      });

      await store.dispatchAndWait(LoadAllBlockStatesAction());

      expect(store.state.blockStates.items.map((m) => m.id), ['b1', 'b2']);
      expect(store.state.blockStates.hasNextPage, isFalse);
    });

    test('loads nothing when every page is there', () async {
      const loaded = BlockStateModel(id: 'b1', uiName: 'Seats');
      final store = _storeWith(items: [loaded]);
      final before = store.state;

      await store.dispatchAndWait(LoadAllBlockStatesAction());

      expect(store.state, before);
    });
  });

  group('UpdateBlockStateAction', () {
    test('stages the blockstate and marks the section unsaved', () async {
      const listed = BlockStateModel(id: 'b1', uiName: 'Petals');
      final store = _storeWith(items: [listed], selected: listed);
      final changed = listed.copyWith(
        rules: const [BlockStateRule(model: 'minecraft:block/seat')],
      );

      await store.dispatchAndWait(UpdateBlockStateAction(changed));

      expect(store.state.selectedBlockState, changed);
      expect(store.state.unsavedChanges, NavigationEntry.blockstates);
      // Only staged, the list keeps what is saved.
      expect(store.state.blockStates.items.single, listed);
    });
  });

  group('BlockStateDatabaseUpdate', () {
    test('saves the selection and puts the answer into the list', () async {
      const listed = BlockStateModel(id: 'b1', uiName: 'Petals');
      final selected = listed.copyWith(
        rules: const [
          BlockStateRule(name: 'Seat', model: 'minecraft:block/seat'),
        ],
      );
      final store = _storeWith(items: [listed], selected: selected)
        ..dispatchSync(UpdateBlockStateAction(selected));
      _respond(selected.toJson());

      await store.dispatchAndWait(BlockStateDatabaseUpdate());

      expect(store.state.blockStates.items.single.rules.single.name, 'Seat');
      expect(store.state.selectedBlockState!.rules.single.name, 'Seat');
      expect(store.state.unsavedChanges, isNull);
    });

    test('does nothing without a selection', () async {
      final store = _storeWith(items: const []);
      final before = store.state;

      await store.dispatchAndWait(BlockStateDatabaseUpdate());

      expect(store.state, before);
    });
  });

  group('BlockStateNotesUpdateAction', () {
    test('replaces the list entry and only patches the notes into a '
        'selection of the same blockstate', () async {
      const listed = BlockStateModel(id: 'b1', uiName: 'Petals');
      // The selection carries unsaved rules that must survive.
      final selected = listed.copyWith(
        rules: const [BlockStateRule(model: 'minecraft:block/seat')],
      );
      final store = _storeWith(items: [listed], selected: selected);
      _respond({'id': 'b1', 'uiName': 'Petals', 'comment': 'Boss room'});

      await store.dispatchAndWait(
        BlockStateNotesUpdateAction(listed, 'Boss room'),
      );

      expect(store.state.blockStates.items.single.comment, 'Boss room');
      expect(store.state.selectedBlockState!.comment, 'Boss room');
      expect(store.state.selectedBlockState!.rules, selected.rules);
    });
  });

  group('RemoveSelectBlockStateAction', () {
    test('clears the selection and its unsaved changes', () async {
      const listed = BlockStateModel(id: 'b1', uiName: 'Petals');
      final store = _storeWith(items: [listed], selected: listed)
        ..dispatchSync(UpdateBlockStateAction(listed));

      await store.dispatchAndWait(RemoveSelectBlockStateAction());

      expect(store.state.selectedBlockState, isNull);
      expect(store.state.unsavedChanges, isNull);
    });
  });
}
