import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';

/// Selects a specific attribute model and updates the state.
///
/// This action is used to set the currently selected attribute in the application state.
/// The selected attribute is typically used for editing, viewing details, or other operations
/// that require a specific attribute to be active.
class SelectAttributeAction extends ReduxAction<AppState> {
  final AttributeModel model;

  SelectAttributeAction(this.model);

  @override
  AppState reduce() => state.copyWith(selectedAttribute: model);
}

/// Clears the currently selected attribute from the state.
///
/// This action removes the selected attribute, typically used when navigating away
/// from an attribute detail view or canceling an operation. If no attribute is
/// currently selected, this action has no effect and returns null.
class RemoveSelectAttributeAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    if (state.selectedAttribute == null) return null;
    return state.copyWith(selectedAttribute: null);
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

    if (hasExisting && canLoadMore) {
      if (state.isLoadingAttributesMore) return null;
      dispatchSync(_SetAttributesLoadMore(true));
      try {
        final current = state.attributes;
        final nextPage = current.currentPage + 1;
        final size = 10;
        final next = await ApiService().attributeApi.getPage(
          page: nextPage,
          size: size,
          projectId: state.selectedProject?.id,
        );

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
        return state.copyWith(attributes: updated);
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

/// Updates the currently selected attribute in the state without database persistence.
///
/// This action is used for local state updates, such as when editing attribute
/// properties in a form before saving. The changes are only reflected in the
/// application state and do not trigger any API calls.
class UpdateAttributeAction extends ReduxAction<AppState> {
  final AttributeModel newEntry;

  UpdateAttributeAction(this.newEntry);

  @override
  Future<AppState?> reduce() async =>
      store.state.copyWith(selectedAttribute: newEntry);
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
class AttributeAddAction extends ReduxAction<AppState> {
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
class AttributeDatabaseUpdate extends ReduxAction<AppState> {
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

    return _updateAttributesInState(state, updatedList, dbModel);
  }
}
