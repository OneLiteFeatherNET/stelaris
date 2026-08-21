import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';

class SelectSoundAction extends ReduxAction<AppState> {
  final SoundEventModel model;

  SelectSoundAction(this.model);

  @override
  AppState reduce() => state.copyWith(selectedSoundEvent: model);
}

class RemoveSelectedSoundEvent extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    if (state.selectedFont == null) return null;
    return state.copyWith(selectedSoundEvent: null);
  }
}

class InitSoundAction extends ReduxAction<AppState> {
  InitSoundAction();

  @override
  Future<AppState?> reduce() async {
    // If we already have items and more pages, treat this as load-more.
    final hasExisting = state.soundEvents.items.isNotEmpty;
    final canLoadMore = state.soundEvents.hasNextPage;

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

    final SoundEventModel? selectedModel =
        state.selectedSoundEvent?.id == model.id
        ? null
        : state.selectedSoundEvent;

    return _updateSoundEventsInState(state, updatedList, selectedModel);
  }
}

class SoundAddAction extends ReduxAction<AppState> {
  final SoundEventModel _model;

  SoundAddAction(this._model);

  @override
  Future<AppState?> reduce() async {
    final SoundEventModel databaseModel = await ApiService().soundApi.add(
      _model,
    );
    final List<SoundEventModel> updatedList = List.of(
      state.soundEvents.items,
      growable: true,
    )..add(databaseModel);

    return _updateSoundEventsInState(state, updatedList, databaseModel);
  }
}

class UpdateSoundAction extends ReduxAction<AppState> {
  final SoundEventModel newEntry;

  UpdateSoundAction(this.newEntry);

  @override
  Future<AppState?> reduce() async =>
      state.copyWith(selectedSoundEvent: newEntry);
}

class SoundDatabaseUpdate extends ReduxAction<AppState> {
  SoundDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedSoundEvent == null) return null;
    final SoundEventModel selected = state.selectedSoundEvent!;
    final SoundEventModel dbModel = await ApiService().soundApi.update(
      selected,
    );
    final List<SoundEventModel> updatedList = List.of(
      state.soundEvents.items,
      growable: true,
    );
    final int index = updatedList.indexWhere(
      (element) => element.id == selected.id,
    );

    if (index != -1) {
      updatedList[index] = dbModel;
    }

    return _updateSoundEventsInState(state, updatedList, dbModel);
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
