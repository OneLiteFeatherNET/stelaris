import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/api/state/actions/copy_model_action.dart';
import 'package:stelaris/api/state/actions/paginated_loading.dart';
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
    return state.copyWith(advancements: await _firstPage(state));
  }
}

/// Loads the first page of advancements when none are loaded, and the next page
/// otherwise. The overview dispatches it when it opens.
class InitAdvancementAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    if (state.advancements.items.isEmpty) {
      return state.copyWith(advancements: await _firstPage(state));
    }
    await dispatchAndWait(LoadMoreAdvancementsAction());
    return null;
  }
}

/// Appends the next page of advancements, if there is one.
///
/// While it loads, `isWaiting(LoadMoreAdvancementsAction)` is true, and another one
/// dispatched meanwhile is dropped.
class LoadMoreAdvancementsAction extends ReduxAction<AppState> with NonReentrant {
  @override
  Future<AppState?> reduce() async {
    final current = state.advancements;
    if (!current.hasNextPage) return null;

    final next = await ApiService().advancementApi.getPage(
      page: current.currentPage + 1,
      size: current.requestSize,
      projectId: state.selectedProject?.id,
    );

    // A project switch or refresh replaced the list while the page
    // loaded, so the page no longer continues it.
    if (!identical(state.advancements, current)) return null;

    return state.copyWith(advancements: current.append(next));
  }
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
    return state.copyWith(
      advancements: state.advancements.adding(databaseModel),
      selectedAdvancement: databaseModel,
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
    return state.copyWith(
      advancements: state.advancements.adding(
        copied.copyWith(projectId: result.targetProjectId),
      ),
    );
  }
}

class AdvancementRemoveAction extends ReduxAction<AppState> {
  final AdvancementModel model;

  AdvancementRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().advancementApi.remove(model);
    // The selection stays: when deleting from the detail page, that page is
    // still mounted during its exit transition and reads it. The page's
    // onDispose clears it.
    return state.copyWith(
      advancements: state.advancements.removingWhere(
        (element) => element.id == model.id,
      ),
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

    return state
        .copyWith(
          advancements: state.advancements.replacingWhere(
            (element) => element.id == selected.id,
            dbModel,
          ),
          selectedAdvancement: dbModel,
        )
        .clearUnsavedChanges(NavigationEntry.advancements);
  }
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
    final selected = state.selectedAdvancement;
    return state.copyWith(
      advancements: state.advancements.replacingWhere(
        (item) => item.id == response.id,
        response,
      ),
      selectedAdvancement: selected?.id == response.id
          ? selected!.copyWith(comment: response.comment)
          : selected,
    );
  }
}

/// Page 1 of the advancements of the open project, in the size of the
/// loaded pages.
Future<PaginatedResult<AdvancementModel>> _firstPage(AppState state) =>
    ApiService().advancementApi.getPage(
      page: 1,
      size: state.advancements.requestSize,
      projectId: state.selectedProject?.id,
    );
