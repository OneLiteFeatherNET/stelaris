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

/// Always refetches page 1 and replaces the current list, used by the
/// grid's manual refresh, as opposed to [InitBlockStateAction] which only
/// loads the next page or the very first one.
class RefreshBlockStateAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    return state.copyWith(blockStates: await _firstPage(state));
  }
}

/// Loads the first page of the blockstates, or the next one when some are
/// loaded already and more are left.
class InitBlockStateAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final hasExisting = state.blockStates.items.isNotEmpty;
    final canLoadMore = state.blockStates.hasNextPage;

    if (hasExisting && !canLoadMore) return null;

    if (hasExisting && canLoadMore) {
      if (state.isLoadingMoreBlockStates) return null;
      dispatchSync(_SetBlockStatesLoadMore(true));
      try {
        final current = state.blockStates;
        final next = await ApiService().blockStateApi.getPage(
          page: current.currentPage + 1,
          size: current.requestSize,
          projectId: state.selectedProject?.id,
        );

        // A project switch or refresh replaced the list while the page
        // loaded, so the page no longer continues it.
        if (!identical(state.blockStates, current)) return null;

        // The flag is cleared here as well: this state is applied after the
        // `finally` below and would otherwise set the flag back to true.
        return state.copyWith(
          blockStates: current.append(next),
          isLoadingMoreBlockStates: false,
        );
      } finally {
        dispatchSync(_SetBlockStatesLoadMore(false));
      }
    }
    return state.copyWith(blockStates: await _firstPage(state));
  }
}

/// Keeps a second load-more request out while one is running.
class _SetBlockStatesLoadMore extends ReduxAction<AppState> {
  final bool value;

  _SetBlockStatesLoadMore(this.value);

  @override
  AppState reduce() => state.copyWith(isLoadingMoreBlockStates: value);
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

/// Page 1 of the blockstates of the open project, in the size of the loaded
/// pages.
Future<PaginatedResult<BlockStateModel>> _firstPage(AppState state) =>
    ApiService().blockStateApi.getPage(
      page: 1,
      size: state.blockStates.requestSize,
      projectId: state.selectedProject?.id,
    );
