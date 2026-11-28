import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/paginated_loading.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Selects [model] for its detail page and drops the blockstate section's
/// pending edits.
class SelectBlockStateAction extends ReduxAction<AppState> {
  final BlockStateModel model;

  SelectBlockStateAction(this.model);

  @override
  AppState reduce() => state
      .copyWith(selectedBlockState: model)
      .clearUnsavedChanges(NavigationEntry.blockstates);
}

/// Clears the selection when the detail page is left.
class RemoveSelectBlockStateAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    if (state.selectedBlockState == null) return null;
    return state
        .copyWith(selectedBlockState: null)
        .clearUnsavedChanges(NavigationEntry.blockstates);
  }
}

/// Stages [newEntry] as the selection. The header's save sends it to the
/// backend through [BlockStateDatabaseUpdate].
class UpdateBlockStateAction extends ReduxAction<AppState> {
  final BlockStateModel newEntry;

  UpdateBlockStateAction(this.newEntry);

  @override
  AppState reduce() => state.copyWith(
    selectedBlockState: newEntry,
    unsavedChanges: NavigationEntry.blockstates,
  );
}

final _modelList = ModelList<BlockStateModel>(
  of: (state) => state.blockStates,
  withList: (state, list) => state.copyWith(blockStates: list),
  api: () => ApiService().blockStateApi,
);

/// Refetches the first page of the blockstates and replaces what was loaded.
class RefreshBlockStateAction extends RefreshListAction<BlockStateModel> {
  RefreshBlockStateAction() : super(_modelList);
}

/// Loads the first page of the blockstates when none is loaded.
class InitBlockStateAction extends InitListAction<BlockStateModel> {
  InitBlockStateAction() : super(_modelList);
}

/// Appends the next page of the blockstates. While it loads,
/// `isWaiting(LoadMoreBlockStatesAction)` is true.
class LoadMoreBlockStatesAction extends LoadMoreListAction<BlockStateModel> {
  LoadMoreBlockStatesAction() : super(_modelList);
}

/// Loads the pages of the blockstates that are still missing, so every
/// context of a block is known: the overlaps between them and their count
/// would miss the ones on a page not loaded yet.
///
/// A project holds few blockstates, so this costs only a few requests. It
/// stops early when a page brings nothing new, e.g. while a load-more of the
/// list is still running.
class LoadAllBlockStatesAction extends ReduxAction<AppState> with NonReentrant {
  @override
  Future<AppState?> reduce() async {
    if (state.blockStates.items.isEmpty) {
      await dispatchAndWait(InitBlockStateAction());
    }
    while (state.blockStates.hasNextPage) {
      final before = state.blockStates;
      await dispatchAndWait(LoadMoreBlockStatesAction());
      if (identical(state.blockStates, before)) break;
    }
    return null;
  }
}

/// Adds [model] to the backend and selects what it answers, with the id it
/// was given.
class BlockStateAddAction extends ReduxAction<AppState> with NonReentrant {
  final BlockStateModel model;

  BlockStateAddAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final toAdd = model.projectId == null && state.selectedProject != null
        ? model.copyWith(projectId: state.selectedProject!.id)
        : model;
    final BlockStateModel databaseModel = await ApiService().blockStateApi.add(
      toAdd,
    );
    return state.copyWith(
      blockStates: state.blockStates.adding(databaseModel),
      selectedBlockState: databaseModel,
    );
  }
}

/// Deletes [model] in the backend and drops it from the list.
class BlockStateRemoveAction extends ReduxAction<AppState> {
  final BlockStateModel model;

  BlockStateRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().blockStateApi.remove(model);
    // The selection stays: when deleting from the detail page, that page is
    // still mounted during its exit transition and reads it. The page's
    // onDispose clears it.
    return state.copyWith(
      blockStates: state.blockStates.removingWhere(
        (element) => element.id == model.id,
      ),
    );
  }
}

/// Saves the selected blockstate and puts what the backend answers into the
/// list and the selection.
class BlockStateDatabaseUpdate extends ReduxAction<AppState> with Throttle {
  @override
  Future<AppState?> reduce() async {
    final selected = state.selectedBlockState;
    if (selected == null) return null;

    final BlockStateModel dbModel = await ApiService().blockStateApi.update(
      selected,
    );
    return state
        .copyWith(
          blockStates: state.blockStates.replacingWhere(
            (element) => element.id == selected.id,
            dbModel,
          ),
          selectedBlockState: dbModel,
        )
        .clearUnsavedChanges(NavigationEntry.blockstates);
  }
}

/// Saves new [notes] for [model] straight from the overview. The list entry
/// is replaced with the server's response; a selection of the same
/// blockstate only gets the new notes, so its unsaved edits survive.
class BlockStateNotesUpdateAction extends ReduxAction<AppState>
    with NonReentrant {
  final BlockStateModel model;
  final String? notes;

  BlockStateNotesUpdateAction(this.model, this.notes);

  @override
  Future<AppState?> reduce() async {
    final BlockStateModel response = await ApiService().blockStateApi.update(
      model.copyWith(comment: notes),
    );
    final selected = state.selectedBlockState;
    return state.copyWith(
      blockStates: state.blockStates.replacingWhere(
        (item) => item.id == response.id,
        response,
      ),
      selectedBlockState: selected?.id == response.id
          ? selected!.copyWith(comment: response.comment)
          : selected,
    );
  }
}
