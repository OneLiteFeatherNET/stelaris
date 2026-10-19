import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/api/state/actions/copy_model_action.dart';
import 'package:stelaris/util/copy_model_result.dart';

/// Selects [model] for its detail page and drops the attribute section's
/// pending edits.
class SelectAttributeAction extends ReduxAction<AppState> {
  final AttributeModel model;

  SelectAttributeAction(this.model);

  @override
  AppState reduce() => state
      .copyWith(selectedAttribute: model)
      .clearUnsavedChanges(NavigationEntry.attributes);
}

/// Clears the selection when the detail page is left.
class RemoveSelectAttributeAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    if (state.selectedAttribute == null) return null;
    return state
        .copyWith(selectedAttribute: null)
        .clearUnsavedChanges(NavigationEntry.attributes);
  }
}

/// Stages [newEntry] as the selection. The header's save sends it to the
/// backend through [AttributeDatabaseUpdate].
class UpdateAttributeAction extends ReduxAction<AppState> {
  final AttributeModel newEntry;

  UpdateAttributeAction(this.newEntry);

  @override
  AppState reduce() => state.copyWith(
    selectedAttribute: newEntry,
    unsavedChanges: NavigationEntry.attributes,
  );
}

/// Always refetches page 1 and replaces the current list, regardless of
/// how many pages were already loaded — used by the grid's manual refresh
/// button, as opposed to [InitAttributeAction] which only ever loads the
/// next page or the very first page.
class RefreshAttributeAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final PaginatedResult<AttributeModel> result = await ApiService()
        .attributeApi
        .getPage(
          page: 1,
          size: state.attributes.pageSize == 0 ? 10 : state.attributes.pageSize,
          projectId: state.selectedProject?.id,
        );
    return state.copyWith(attributes: result);
  }
}

/// Initializes or loads more attributes from the API.
///
/// This action handles both initial loading and pagination of attributes:
/// - If attributes already exist and more pages are available, it loads the next page
/// - If no attributes exist or pagination is complete, it performs an initial load
///
/// During load-more operations, it sets a loading flag to prevent duplicate requests
/// and merges new results with existing data. The action maintains pagination metadata
/// including current page, total items, and page size information.
class InitAttributeAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    // If we already have items and more pages, treat this as load-more.
    final hasExisting = state.attributes.items.isNotEmpty;
    final canLoadMore = state.attributes.hasNextPage;

    if (hasExisting && !canLoadMore) return null;

    if (hasExisting && canLoadMore) {
      if (state.isLoadingAttributesMore) return null;
      dispatchSync(_SetAttributesLoadMore(true));
      try {
        final current = state.attributes;
        final nextPage = current.currentPage + 1;
        final size = current.pageSize == 0 ? 10 : current.pageSize;
        final next = await ApiService().attributeApi.getPage(
          page: nextPage,
          size: size,
          projectId: state.selectedProject?.id,
        );

        // A project switch or refresh replaced the list while the page
        // loaded, so the page no longer continues it.
        if (!identical(state.attributes, current)) return null;

        final merged = List<AttributeModel>.of(current.items)
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
        // The flag is cleared here as well: this state is applied after the
        // `finally` below and would otherwise set the flag back to true.
        return state.copyWith(
          attributes: updated,
          isLoadingAttributesMore: false,
        );
      } finally {
        dispatchSync(_SetAttributesLoadMore(false));
      }
    } else {
      // Initial load (or refresh)
      final PaginatedResult<AttributeModel> result = await ApiService()
          .attributeApi
          .getPage(
            page: 1,
            size: state.attributes.pageSize == 0
                ? 10
                : state.attributes.pageSize,
            projectId: state.selectedProject?.id,
          );
      return state.copyWith(attributes: result);
    }
  }
}

/// Internal action to manage the loading state for attribute pagination.
///
/// This private action controls the `isLoadingAttributesMore` flag in the state,
/// preventing multiple simultaneous load-more requests. It's used internally
/// by InitAttributeAction during pagination operations.
class _SetAttributesLoadMore extends ReduxAction<AppState> {
  final bool value;
  _SetAttributesLoadMore(this.value);
  @override
  AppState reduce() => state.copyWith(isLoadingAttributesMore: value);
}

/// Helper method to update the attributes list in state
///
/// Centralizes the logic for updating the attributes list and selected attribute
/// in the state. This reduces code duplication across multiple actions that
/// modify the attributes collection.
AppState _updateAttributesInState(
  AppState state,
  List<AttributeModel> newItems,
  AttributeModel? selectedAttribute, {
  int? totalItems,
}) {
  final updated = state.attributes.copyWith(
    items: newItems,
    totalItems: totalItems ?? state.attributes.totalItems,
    totalPages: state.attributes.totalPages,
    currentPage: state.attributes.currentPage,
    pageSize: state.attributes.pageSize,
  );
  return state.copyWith(
    attributes: updated,
    selectedAttribute: selectedAttribute,
  );
}

/// Adds a new attribute to both the database and application state.
///
/// This action performs the following operations:
/// 1. Sends the attribute model to the API for persistence
/// 2. Adds the returned database model (with assigned ID) to the local attributes list
/// 3. Sets the newly created attribute as the currently selected attribute
///
/// The action ensures the local state reflects the actual database state by using
/// the model returned from the API rather than the input model.
class AttributeAddAction extends ReduxAction<AppState> with NonReentrant {
  final AttributeModel model;

  AttributeAddAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final toAdd = model.projectId == null && state.selectedProject != null
        ? model.copyWith(projectId: state.selectedProject!.id)
        : model;
    final AttributeModel databaseModel = await ApiService().attributeApi.add(
      toAdd,
    );
    final List<AttributeModel> updatedList = List.of(
      state.attributes.items,
      growable: true,
    )..add(databaseModel);

    return _updateAttributesInState(
      state,
      updatedList,
      databaseModel,
      totalItems: state.attributes.totalItems + 1,
    );
  }
}

/// Copies [source] as described by [result]. The copy joins the list only
/// when it landed in the open project; the selection is left alone.
class AttributeCopyAction extends ReduxAction<AppState>
    with NonReentrant, CopyModelAction {
  final AttributeModel source;
  @override
  final CopyModelResult result;

  AttributeCopyAction(this.source, this.result);

  @override
  Future<AppState?> reduce() async {
    final AttributeModel copied = await ApiService().attributeApi.copy(
      source.copyWith(projectId: sourceProjectId(source.projectId)),
      targetProjectId: result.targetProjectId,
      targetName: result.name,
      targetKey: result.key,
      relations: result.relations,
    );
    if (!copiesIntoOpenProject) return null;
    return _updateAttributesInState(
      state,
      [
        ...state.attributes.items,
        copied.copyWith(projectId: result.targetProjectId),
      ],
      state.selectedAttribute,
      totalItems: state.attributes.totalItems + 1,
    );
  }
}

/// Removes an attribute from both the database and application state.
///
/// This action performs the following operations:
/// 1. Sends a delete request to the API for the specified attribute
/// 2. Removes the attribute from the local attributes list
/// 3. Clears the selected attribute if it matches the deleted attribute
///
/// The action maintains referential integrity by checking if the deleted attribute
/// was the currently selected one and clearing the selection if necessary.
class AttributeRemoveAction extends ReduxAction<AppState> {
  final AttributeModel model;

  AttributeRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().attributeApi.remove(model);
    final List<AttributeModel> updatedList = List.of(
      state.attributes.items,
      growable: true,
    )..remove(model);

    final AttributeModel? selectedModel =
        state.selectedAttribute?.id == model.id
        ? null
        : state.selectedAttribute;

    return _updateAttributesInState(
      state,
      updatedList,
      selectedModel,
      totalItems: state.attributes.totalItems - 1,
    );
  }
}

/// Updates the currently selected attribute in both the database and application state.
///
/// This action performs the following operations:
/// 1. Validates that an attribute is currently selected
/// 2. Sends the updated attribute to the API for persistence
/// 3. Replaces the old attribute in the local list with the updated version
/// 4. Updates the selected attribute reference with the database model
///
/// If no attribute is currently selected, the action returns null and performs no operations.
/// The action ensures data consistency by using the model returned from the API.
class AttributeDatabaseUpdate extends ReduxAction<AppState> with Throttle {
  @override
  Future<AppState?> reduce() async {
    if (state.selectedAttribute == null) return null;

    final AttributeModel selected = state.selectedAttribute!;
    final AttributeModel dbModel = await ApiService().attributeApi.update(
      selected,
    );

    final List<AttributeModel> updatedList = List.of(
      state.attributes.items,
      growable: true,
    );
    final int index = updatedList.indexWhere(
      (element) => element.id == selected.id,
    );

    if (index != -1) {
      updatedList[index] = dbModel;
    }

    return _updateAttributesInState(
      state,
      updatedList,
      dbModel,
    ).clearUnsavedChanges(NavigationEntry.attributes);
  }
}

/// Saves new [notes] for [model] straight from the overview. The list entry
/// is replaced with the server's response; a selection of the same
/// attribute only gets the new notes, so its unsaved edits survive.
class AttributeNotesUpdateAction extends ReduxAction<AppState>
    with NonReentrant {
  final AttributeModel model;
  final String? notes;

  AttributeNotesUpdateAction(this.model, this.notes);

  @override
  Future<AppState?> reduce() async {
    final AttributeModel response = await ApiService().attributeApi.update(
      model.copyWith(comment: notes),
    );
    final List<AttributeModel> items = List.of(
      state.attributes.items,
      growable: true,
    );
    final int index = items.indexWhere((item) => item.id == response.id);
    if (index != -1) {
      items[index] = response;
    }
    final selected = state.selectedAttribute;
    return _updateAttributesInState(
      state,
      items,
      selected?.id == response.id
          ? selected!.copyWith(comment: response.comment)
          : selected,
    );
  }
}
