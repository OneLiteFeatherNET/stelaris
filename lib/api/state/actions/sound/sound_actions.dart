import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/api/state/actions/copy_model_action.dart';
import 'package:stelaris/api/state/actions/paginated_loading.dart';
import 'package:stelaris/util/copy_model_result.dart';

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
    return state.copyWith(soundEvents: await _firstPage(state));
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
        final next = await ApiService().soundApi.getPage(
          page: current.currentPage + 1,
          size: current.requestSize,
          projectId: state.selectedProject?.id,
        );

        // A project switch or refresh replaced the list while the page
        // loaded, so the page no longer continues it.
        if (!identical(state.soundEvents, current)) return null;

        final updated = current.append(next);
        // The flag is cleared here as well: this state is applied after the
        // `finally` below and would otherwise set the flag back to true.
        return state.copyWith(
          soundEvents: updated,
          isLoadingMoreSoundEvents: false,
        );
      } finally {
        dispatchSync(_SetLoadMoreSoundEventModels(false));
      }
    } else {
      // Initial load (or refresh)
      return state.copyWith(soundEvents: await _firstPage(state));
    }
  }
}

/// Copies [source] as described by [result]. The copy joins the list only
/// when it landed in the open project; the selection is left alone.
class SoundCopyAction extends ReduxAction<AppState>
    with NonReentrant, CopyModelAction {
  final SoundEventModel source;
  @override
  final CopyModelResult result;

  SoundCopyAction(this.source, this.result);

  @override
  Future<AppState?> reduce() async {
    final SoundEventModel copied = await ApiService().soundApi.copy(
      source.copyWith(projectId: sourceProjectId(source.projectId)),
      targetProjectId: result.targetProjectId,
      targetName: result.name,
      targetKey: result.key,
      relations: result.relations,
    );
    if (!copiesIntoOpenProject) return null;
    return state.copyWith(
      soundEvents: state.soundEvents.adding(
        copied.copyWith(projectId: result.targetProjectId),
      ),
    );
  }
}

class SoundRemoveAction extends ReduxAction<AppState> {
  final SoundEventModel model;

  SoundRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().soundApi.remove(model);
    // The selection stays: when deleting from the detail page, that page is
    // still mounted during its exit transition and reads it. The page's
    // onDispose clears it.
    return state.copyWith(
      soundEvents: state.soundEvents.removingWhere(
        (element) => element.id == model.id,
      ),
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
    return state.copyWith(
      soundEvents: state.soundEvents.adding(databaseModel),
      selectedSoundEvent: databaseModel,
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
    return state
        .copyWith(
          soundEvents: state.soundEvents.replacingWhere(
            (element) => element.id == selected.id,
            response,
          ),
          selectedSoundEvent: dbModel,
        )
        .clearUnsavedChanges(NavigationEntry.sound);
  }
}

/// Saves new [notes] for [model] straight from the overview, without going
/// through the selection and its unsaved-changes flow. The list entry is
/// replaced with the server's response. A selection of the same sound event
/// only gets the new notes — its other fields may hold unsaved edits, and a
/// later Save must not send the old notes back.
class SoundNotesUpdateAction extends ReduxAction<AppState> with NonReentrant {
  final SoundEventModel model;
  final String? notes;

  SoundNotesUpdateAction(this.model, this.notes);

  @override
  Future<AppState?> reduce() async {
    final SoundEventModel response = await ApiService().soundApi.update(
      model.copyWith(comment: notes),
    );
    final selected = state.selectedSoundEvent;
    return state.copyWith(
      soundEvents: state.soundEvents.replacingWhere(
        (item) => item.id == response.id,
        response,
      ),
      selectedSoundEvent: selected?.id == response.id
          ? selected!.copyWith(comment: response.comment)
          : selected,
    );
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

/// Page 1 of the sound events of the open project, in the size of the
/// loaded pages.
Future<PaginatedResult<SoundEventModel>> _firstPage(AppState state) =>
    ApiService().soundApi.getPage(
      page: 1,
      size: state.soundEvents.requestSize,
      projectId: state.selectedProject?.id,
    );
