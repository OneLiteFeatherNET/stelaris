import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/api/state/actions/copy_model_action.dart';
import 'package:stelaris/api/state/actions/paginated_loading.dart';
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

final _modelList = ModelList<AttributeModel>(
  of: (state) => state.attributes,
  withList: (state, list) => state.copyWith(attributes: list),
  api: () => ApiService().attributeApi,
);

/// Refetches the first page of the attributes and replaces what was loaded.
class RefreshAttributeAction extends RefreshListAction<AttributeModel> {
  RefreshAttributeAction() : super(_modelList);
}

/// Loads the first page of the attributes, or the next one when some are
/// loaded.
class InitAttributeAction extends InitListAction<AttributeModel> {
  InitAttributeAction() : super(_modelList, LoadMoreAttributesAction.new);
}

/// Appends the next page of the attributes. While it loads,
/// `isWaiting(LoadMoreAttributesAction)` is true.
class LoadMoreAttributesAction extends LoadMoreListAction<AttributeModel> {
  LoadMoreAttributesAction() : super(_modelList);
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
    return state.copyWith(
      attributes: state.attributes.adding(databaseModel),
      selectedAttribute: databaseModel,
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
    return state.copyWith(
      attributes: state.attributes.adding(
        copied.copyWith(projectId: result.targetProjectId),
      ),
    );
  }
}

/// Removes an attribute from both the database and application state.
///
/// This action performs the following operations:
/// 1. Sends a delete request to the API for the specified attribute
/// 2. Removes the attribute with the same id from the local attributes list
class AttributeRemoveAction extends ReduxAction<AppState> {
  final AttributeModel model;

  AttributeRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().attributeApi.remove(model);
    // The selection stays: when deleting from the detail page, that page is
    // still mounted during its exit transition and reads it. The page's
    // onDispose clears it.
    return state.copyWith(
      attributes: state.attributes.removingWhere(
        (element) => element.id == model.id,
      ),
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

    return state
        .copyWith(
          attributes: state.attributes.replacingWhere(
            (element) => element.id == selected.id,
            dbModel,
          ),
          selectedAttribute: dbModel,
        )
        .clearUnsavedChanges(NavigationEntry.attributes);
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
    final selected = state.selectedAttribute;
    return state.copyWith(
      attributes: state.attributes.replacingWhere(
        (item) => item.id == response.id,
        response,
      ),
      selectedAttribute: selected?.id == response.id
          ? selected!.copyWith(comment: response.comment)
          : selected,
    );
  }
}
