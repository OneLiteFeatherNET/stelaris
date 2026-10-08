import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/api/state/actions/copy_model_action.dart';
import 'package:stelaris/util/copy_model_result.dart';

class SelectedAdvancementAction extends ReduxAction<AppState> {
  final AdvancementModel model;

  SelectedAdvancementAction(this.model);

  @override
  AppState reduce() => state
      .copyWith(selectedAdvancement: model)
      .clearUnsavedChanges(NavigationEntry.advancements);
}

class RemoveSelectAdvancementAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    if (state.selectedAdvancement == null) return null;
    return state
        .copyWith(selectedAdvancement: null)
        .clearUnsavedChanges(NavigationEntry.advancements);
  }
}

/// Always refetches page 1 and replaces the current list, regardless of
/// how many pages were already loaded — used by the grid's manual refresh
/// button, as opposed to [InitAdvancementAction] which only ever loads the
/// next page or the very first page.
class RefreshAdvancementAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final PaginatedResult<AdvancementModel> result = await ApiService()
        .advancementApi
        .getPage(
          page: 1,
          size: state.advancements.pageSize == 0
              ? 10
              : state.advancements.pageSize,
          projectId: state.selectedProject?.id,
        );
    return state.copyWith(advancements: result);
  }
}

class InitAdvancementAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    // If we already have items and more pages, treat this as load-more.
    final hasExisting = state.advancements.items.isNotEmpty;
    final canLoadMore = state.advancements.hasNextPage;

    if (hasExisting && !canLoadMore) return null;

    if (hasExisting && canLoadMore) {
      if (state.isLoadingMoreAdvancements) return null;
      dispatchSync(_SetAdvancementsLoadMore(true));
      try {
        final current = state.advancements;
        final nextPage = current.currentPage + 1;
        final size = 10;
        final next = await ApiService().advancementApi.getPage(
          page: nextPage,
          size: size,
          projectId: state.selectedProject?.id,
        );

        final merged = List<AdvancementModel>.of(current.items)
          ..addAll(next.items);
        final updated = current.copyWith(
          items: merged,
          totalItems: next.totalItems != 0
              ? next.totalItems
              : current.totalItems,
          totalPages: next.totalPages != 0
              ? next.totalPages
              : current.totalPages,
          currentPage: next.currentPage != 0 ? next.currentPage : nextPage,
          pageSize: next.pageSize != 0 ? next.pageSize : size,
        );
        return state.copyWith(advancements: updated);
      } finally {
        dispatchSync(_SetAdvancementsLoadMore(false));
      }
    } else {
      // Initial load (or refresh)
      final PaginatedResult<AdvancementModel> result = await ApiService()
          .advancementApi
          .getPage(
            page: 1,
            size: state.advancements.pageSize == 0
                ? 10
                : state.advancements.pageSize,
            projectId: state.selectedProject?.id,
          );
      return state.copyWith(advancements: result);
    }
  }

  InitAdvancementAction();
}

/// Internal action to manage the loading state for advancements pagination.
///
/// This private action controls the `isLoadingMoreAdvancements` flag in the state,
/// preventing multiple simultaneous load-more requests. It's used internally
/// by InitAdvancementAction during pagination operations.
class _SetAdvancementsLoadMore extends ReduxAction<AppState> {
  final bool value;

  _SetAdvancementsLoadMore(this.value);

  @override
  AppState reduce() => state.copyWith(isLoadingMoreAdvancements: value);
}

class UpdateAdvancementAction extends ReduxAction<AppState> {
  final AdvancementModel newEntry;

  UpdateAdvancementAction(this.newEntry);

  @override
  Future<AppState?> reduce() async => state.copyWith(
    selectedAdvancement: newEntry,
    unsavedChanges: NavigationEntry.advancements,
  );
}

class AdvancementAddAction extends ReduxAction<AppState> with NonReentrant {
  final AdvancementModel model;

  AdvancementAddAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final toAdd = model.projectId == null && state.selectedProject != null
        ? model.copyWith(projectId: state.selectedProject!.id)
        : model;
    final AdvancementModel databaseModel = await ApiService().advancementApi
        .add(toAdd);
    final List<AdvancementModel> updatedList = List.of(
      state.advancements.items,
      growable: true,
    )..add(databaseModel);

    return _updateAdvancementInState(
      state,
      updatedList,
      databaseModel,
      totalItems: state.advancements.totalItems + 1,
    );
  }
}

/// Copies [source] as described by [result]. The copy joins the list only
/// when it landed in the open project; the selection is left alone.
class AdvancementCopyAction extends ReduxAction<AppState>
    with NonReentrant, CopyModelAction {
  final AdvancementModel source;
  @override
  final CopyModelResult result;

  AdvancementCopyAction(this.source, this.result);

  @override
  Future<AppState?> reduce() async {
    final AdvancementModel copied = await ApiService().advancementApi.copy(
      source.copyWith(projectId: sourceProjectId(source.projectId)),
      targetProjectId: result.targetProjectId,
      targetName: result.name,
      targetKey: result.key,
      relations: result.relations,
    );
    if (!copiesIntoOpenProject) return null;
    return _updateAdvancementInState(
      state,
      [
        ...state.advancements.items,
        copied.copyWith(projectId: result.targetProjectId),
      ],
      state.selectedAdvancement,
      totalItems: state.advancements.totalItems + 1,
    );
  }
}

class AdvancementRemoveAction extends ReduxAction<AppState> {
  final AdvancementModel model;

  AdvancementRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().advancementApi.remove(model);
    final List<AdvancementModel> updatedList = List.of(
      state.advancements.items,
      growable: true,
    )..remove(model);

    // The selection stays: when deleting from the detail page, that page is
    // still mounted during its exit transition and reads it. The page's
    // onDispose clears it.
    return _updateAdvancementInState(
      state,
      updatedList,
      state.selectedAdvancement,
      totalItems: state.advancements.totalItems - 1,
    );
  }
}

class AdvancementDatabaseUpdate extends ReduxAction<AppState> with Throttle {
  AdvancementDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedAdvancement == null) return null;

    final AdvancementModel selected = state.selectedAdvancement!;
    final AdvancementModel dbModel = await ApiService().advancementApi.update(
      selected,
    );

    final List<AdvancementModel> updatedList = List.of(
      state.advancements.items,
      growable: true,
    );
    final int index = updatedList.indexWhere(
      (element) => element.id == selected.id,
    );

    if (index != -1) {
      updatedList[index] = dbModel;
    }

    return _updateAdvancementInState(
      state,
      updatedList,
      dbModel,
    ).clearUnsavedChanges(NavigationEntry.advancements);
  }
}

AppState _updateAdvancementInState(
  AppState state,
  List<AdvancementModel> newItems,
  AdvancementModel? selectedItem, {
  int? totalItems,
}) {
  final updated = state.advancements.copyWith(
    items: newItems,
    totalItems: totalItems ?? state.advancements.totalItems,
    totalPages: state.advancements.totalPages,
    currentPage: state.advancements.currentPage,
    pageSize: state.advancements.pageSize,
  );
  return state.copyWith(
    advancements: updated,
    selectedAdvancement: selectedItem,
  );
}

/// Saves new [notes] for [model] straight from the overview, without going
/// through the selection and its unsaved-changes flow. The list entry is
/// replaced with the server's response. A selection of the same model only
/// gets the new notes — its other fields may hold unsaved edits, and a
/// later Save must not send the old notes back.
class AdvancementNotesUpdateAction extends ReduxAction<AppState>
    with NonReentrant {
  final AdvancementModel model;
  final String? notes;

  AdvancementNotesUpdateAction(this.model, this.notes);

  @override
  Future<AppState?> reduce() async {
    final AdvancementModel response = await ApiService().advancementApi.update(
      model.copyWith(comment: notes),
    );
    final List<AdvancementModel> items = List.of(
      state.advancements.items,
      growable: true,
    );
    final int index = items.indexWhere((item) => item.id == response.id);
    if (index != -1) {
      items[index] = response;
    }
    final selected = state.selectedAdvancement;
    return _updateAdvancementInState(
      state,
      items,
      selected?.id == response.id
          ? selected!.copyWith(comment: response.comment)
          : selected,
    );
  }
}
