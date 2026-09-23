import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';

class SelectSoundAction extends ReduxAction<AppState> {
  final SoundEventModel model;

  SelectSoundAction(this.model);

  @override
  AppState reduce() => state
      .copyWith(selectedSoundEvent: model)
      .clearUnsavedChanges(NavigationEntry.sound);
}

class RemoveSelectedSoundEvent extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    if (state.selectedSoundEvent == null) return null;
    return state
        .copyWith(selectedSoundEvent: null)
        .clearUnsavedChanges(NavigationEntry.sound);
  }
}

/// Always refetches page 1 and replaces the current list, regardless of
/// how many pages were already loaded — used by the grid's manual refresh
/// button, as opposed to [InitSoundAction] which only ever loads the next
/// page or the very first page.
class RefreshSoundAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final PaginatedResult<SoundEventModel> result = await ApiService()
        .soundApi
        .getPage(
          page: 1,
          size: state.soundEvents.pageSize == 0 ? 10 : state.soundEvents.pageSize,
          projectId: state.selectedProject?.id,
        );
    return state.copyWith(soundEvents: result);
  }
}

class InitSoundAction extends ReduxAction<AppState> {
  InitSoundAction();

  @override
  Future<AppState?> reduce() async {
    // If we already have items and more pages, treat this as load-more.
    final hasExisting = state.soundEvents.items.isNotEmpty;
    final canLoadMore = state.soundEvents.hasNextPage;

    if (hasExisting && !canLoadMore) return null;

    if (hasExisting && canLoadMore) {
      if (state.isLoadingMoreSoundEvents) return null;
      dispatchSync(_SetLoadMoreSoundEventModels(true));
      try {
        final current = state.soundEvents;
        final nextPage = current.currentPage + 1;
        final size = 10;
        final next = await ApiService().soundApi.getPage(
          page: nextPage,
          size: size,
          projectId: state.selectedProject?.id,
        );

        final merged = List<SoundEventModel>.of(current.items)
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
        return state.copyWith(soundEvents: updated);
      } finally {
        dispatchSync(_SetLoadMoreSoundEventModels(false));
      }
    } else {
      // Initial load (or refresh)
      final PaginatedResult<SoundEventModel> result = await ApiService()
          .soundApi
          .getPage(
            page: 1,
            size: state.soundEvents.pageSize == 0
                ? 10
                : state.soundEvents.pageSize,
            projectId: state.selectedProject?.id,
          );
      return state.copyWith(soundEvents: result);
    }
  }
}

class SoundRemoveAction extends ReduxAction<AppState> {
  final SoundEventModel model;

  SoundRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().soundApi.remove(model);
    final List<SoundEventModel> updatedList = List.of(
      state.soundEvents.items,
      growable: true,
    )..remove(model);

    // The selection stays: when deleting from the detail page, that page is
    // still mounted during its exit transition and reads it. The page's
    // onDispose clears it.
    return _updateSoundEventsInState(
      state,
      updatedList,
      state.selectedSoundEvent,
      totalItems: state.soundEvents.totalItems - 1,
    );
  }
}

class SoundAddAction extends ReduxAction<AppState> with NonReentrant {
  final SoundEventModel _model;

  SoundAddAction(this._model);

  @override
  Future<AppState?> reduce() async {
    final toAdd = _model.projectId == null && state.selectedProject != null
        ? _model.copyWith(projectId: state.selectedProject!.id)
        : _model;
    final SoundEventModel databaseModel = await ApiService().soundApi.add(
      toAdd,
    );
    final List<SoundEventModel> updatedList = List.of(
      state.soundEvents.items,
      growable: true,
    )..add(databaseModel);

    return _updateSoundEventsInState(
      state,
      updatedList,
      databaseModel,
      totalItems: state.soundEvents.totalItems + 1,
    );
  }
}

class UpdateSoundAction extends ReduxAction<AppState> {
  final SoundEventModel newEntry;

  UpdateSoundAction(this.newEntry);

  @override
  Future<AppState?> reduce() async => state.copyWith(
    selectedSoundEvent: newEntry,
    unsavedChanges: NavigationEntry.sound,
  );
}

class SoundDatabaseUpdate extends ReduxAction<AppState> with Throttle {
  SoundDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedSoundEvent == null) return null;
    final SoundEventModel selected = state.selectedSoundEvent!;
    final SoundEventModel response = await ApiService().soundApi.update(
      selected,
    );
    // The update response only carries the form fields — the backend never
    // returns relationships, they have their own endpoints. The list gets
    // the response as is (like a fresh list fetch); the selection keeps the
    // loaded relationships, read after the await so changes made meanwhile
    // aren't lost.
    final dbModel = response.copyWith(
      files: (state.selectedSoundEvent ?? selected).files,
    );
    final List<SoundEventModel> updatedList = List.of(
      state.soundEvents.items,
      growable: true,
    );
    final int index = updatedList.indexWhere(
      (element) => element.id == selected.id,
    );

    if (index != -1) {
      updatedList[index] = response;
    }

    return _updateSoundEventsInState(
      state,
      updatedList,
      dbModel,
    ).clearUnsavedChanges(NavigationEntry.sound);
  }
}

/// Internal action to manage the loading state for sound pagination.
///
/// This private action controls the `isLoadingMoreSoundEvents` flag in the state,
/// preventing multiple simultaneous load-more requests. It's used internally
/// by InitSoundAction during pagination operations.
class _SetLoadMoreSoundEventModels extends ReduxAction<AppState> {
  final bool value;

  _SetLoadMoreSoundEventModels(this.value);

  @override
  AppState reduce() => state.copyWith(isLoadingMoreSoundEvents: value);
}

AppState _updateSoundEventsInState(
  AppState state,
  List<SoundEventModel> newItems,
  SoundEventModel? selectedAttribute, {
  int? totalItems,
}) {
  final updated = state.soundEvents.copyWith(
    items: newItems,
    totalItems: totalItems ?? state.soundEvents.totalItems,
    totalPages: state.soundEvents.totalPages,
    currentPage: state.soundEvents.currentPage,
    pageSize: state.soundEvents.pageSize,
  );
  return state.copyWith(
    soundEvents: updated,
    selectedSoundEvent: selectedAttribute,
  );
}
