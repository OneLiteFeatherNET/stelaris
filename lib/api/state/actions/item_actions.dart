import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/api/state/actions/copy_model_action.dart';
import 'package:stelaris/api/state/actions/paginated_loading.dart';
import 'package:stelaris/util/copy_model_result.dart';

class SelectedItemAction extends ReduxAction<AppState> {
  final ItemModel model;

  SelectedItemAction(this.model);

  @override
  AppState reduce() {
    return state
        .copyWith(selectedItem: model, selectedItemComponents: const [])
        .clearUnsavedChanges(NavigationEntry.items);
  }
}

class RemoveSelectItemAction extends ReduxAction<AppState> {
  RemoveSelectItemAction();

  @override
  AppState? reduce() {
    if (state.selectedItem == null) return null;
    return state
        .copyWith(selectedItem: null, selectedItemComponents: const [])
        .clearUnsavedChanges(NavigationEntry.items);
  }
}

class UpdateItemAction extends ReduxAction<AppState> {
  final ItemModel newEntry;

  UpdateItemAction(this.newEntry);

  @override
  Future<AppState?> reduce() async {
    return state.copyWith(
      selectedItem: newEntry,
      unsavedChanges: NavigationEntry.items,
    );
  }
}

/// Always refetches page 1 and replaces the current list, regardless of
/// how many pages were already loaded — used by the grid's manual refresh
/// button, as opposed to [InitItemAction] which only ever loads the next
/// page or the very first page.
class RefreshItemAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    return state.copyWith(items: await _firstPage(state));
  }
}

class InitItemAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    // If we already have items and more pages, treat this as load-more.
    final hasExisting = state.items.items.isNotEmpty;
    final canLoadMore = state.items.hasNextPage;

    if (hasExisting && !canLoadMore) return null;

    if (hasExisting && canLoadMore) {
      if (state.isLoadingMoreItems) return null;
      dispatchSync(_SetLoadMoreItemModels(true));
      try {
        final current = state.items;
        final next = await ApiService().itemApi.getPage(
          page: current.currentPage + 1,
          size: current.requestSize,
          projectId: state.selectedProject?.id,
        );

        // A project switch or refresh replaced the list while the page
        // loaded, so the page no longer continues it.
        if (!identical(state.items, current)) return null;

        final updated = current.append(next);
        // The flag is cleared here as well: this state is applied after the
        // `finally` below and would otherwise set the flag back to true.
        return state.copyWith(items: updated, isLoadingMoreItems: false);
      } finally {
        dispatchSync(_SetLoadMoreItemModels(false));
      }
    } else {
      // Initial load (or refresh)
      return state.copyWith(items: await _firstPage(state));
    }
  }
}

/// Internal action to manage the loading state for item pagination.
///
/// This private action controls the `isLoadingMoreItems` flag in the state,
/// preventing multiple simultaneous load-more requests. It's used internally
/// by InitItemAction during pagination operations.
class _SetLoadMoreItemModels extends ReduxAction<AppState> {
  final bool value;
  _SetLoadMoreItemModels(this.value);
  @override
  AppState reduce() => state.copyWith(isLoadingMoreItems: value);
}

class ItemAddAction extends ReduxAction<AppState> with NonReentrant {
  final ItemModel _model;

  ItemAddAction(this._model);

  @override
  Future<AppState?> reduce() async {
    final toAdd = _model.projectId == null && state.selectedProject != null
        ? _model.copyWith(projectId: state.selectedProject!.id)
        : _model;
    final ItemModel added = await ApiService().itemApi.add(toAdd);
    return state.copyWith(
      items: state.items.adding(added),
      selectedItem: added,
    );
  }
}

/// Copies [source] as described by [result]. The copy joins the list only
/// when it landed in the open project; the selection is left alone.
class ItemCopyAction extends ReduxAction<AppState>
    with NonReentrant, CopyModelAction {
  final ItemModel source;
  @override
  final CopyModelResult result;

  ItemCopyAction(this.source, this.result);

  @override
  Future<AppState?> reduce() async {
    final ItemModel copied = await ApiService().itemApi.copy(
      source.copyWith(projectId: sourceProjectId(source.projectId)),
      targetProjectId: result.targetProjectId,
      targetName: result.name,
      targetKey: result.key,
      relations: result.relations,
    );
    if (!copiesIntoOpenProject) return null;
    return state.copyWith(
      items: state.items.adding(
        copied.copyWith(projectId: result.targetProjectId),
      ),
    );
  }
}

class ItemRemoveAction extends ReduxAction<AppState> {
  final ItemModel model;

  ItemRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final ItemModel removedEntry = await ApiService().itemApi.remove(model);
    // The selection stays: when deleting from the detail page, that page is
    // still mounted during its exit transition and reads it. The page's
    // onDispose clears it.
    return state.copyWith(
      items: state.items.removingWhere(
        (element) => element.id == removedEntry.id,
      ),
    );
  }
}

class ItemDatabaseUpdate extends ReduxAction<AppState> with Throttle {
  ItemDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;
    final ItemModel selected = state.selectedItem!;
    final ItemModel response = await ApiService().itemApi.update(selected);
    // The update response only carries the form fields — the backend never
    // returns relationships, they have their own endpoints. The list gets
    // the response as is (like a fresh list fetch); the selection keeps the
    // loaded relationships, read after the await so changes made meanwhile
    // aren't lost.
    final current = state.selectedItem ?? selected;
    final dbModel = response.copyWith(
      lore: current.lore,
      enchantments: current.enchantments,
    );
    return state
        .copyWith(
          items: state.items.replacingWhere(
            (item) => item.id == response.id,
            response,
          ),
          selectedItem: dbModel,
        )
        .clearUnsavedChanges(NavigationEntry.items);
  }
}

/// Saves new [notes] for [model] straight from the overview, without going
/// through the selection and its unsaved-changes flow. The list entry is
/// replaced with the server's response. A selection of the same model only
/// gets the new notes — its other fields may hold unsaved edits, and a
/// later Save must not send the old notes back.
class ItemNotesUpdateAction extends ReduxAction<AppState> with NonReentrant {
  final ItemModel model;
  final String? notes;

  ItemNotesUpdateAction(this.model, this.notes);

  @override
  Future<AppState?> reduce() async {
    final ItemModel response = await ApiService().itemApi.update(
      model.copyWith(comment: notes),
    );
    final selected = state.selectedItem;
    return state.copyWith(
      items: state.items.replacingWhere(
        (item) => item.id == response.id,
        response,
      ),
      selectedItem: selected?.id == response.id
          ? selected!.copyWith(comment: response.comment)
          : selected,
    );
  }
}

/// Page 1 of the items of the open project, in the size of the
/// loaded pages.
Future<PaginatedResult<ItemModel>> _firstPage(AppState state) =>
    ApiService().itemApi.getPage(
      page: 1,
      size: state.items.requestSize,
      projectId: state.selectedProject?.id,
    );
