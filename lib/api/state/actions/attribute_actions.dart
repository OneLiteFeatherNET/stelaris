import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/attribute_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/paginated_result.dart';

class SelectAttributeAction extends ReduxAction<AppState> {
  final AttributeModel model;

  SelectAttributeAction(this.model);

  @override
  AppState reduce() => state.copyWith(selectedAttribute: model);
}

class RemoveSelectAttributeAction extends ReduxAction<AppState> {

  @override
  AppState? reduce() {
    if (state.selectedAttribute == null) return null;
    return state.copyWith(selectedAttribute: null);
  }
}

class InitAttributeAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final PaginatedResult<AttributeModel> result = await ApiService().attributeApi.getPage();
    return state.copyWith(attributes: result);
  }
}

class UpdateAttributeAction extends ReduxAction<AppState> {
  final AttributeModel newEntry;

  UpdateAttributeAction(
    this.newEntry,
  );

  @override
  Future<AppState?> reduce() async =>
      store.state.copyWith(selectedAttribute: newEntry);
}

class AttributeAddAction extends ReduxAction<AppState> {
  final AttributeModel model;

  AttributeAddAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final AttributeModel databaseModel =
        await ApiService().attributeApi.add(model);
    final List<AttributeModel> list =
        List.of(state.attributes.items, growable: true);
    list.add(databaseModel);
    final updated = state.attributes.copyWith(
      items: list,
      totalItems: list.length,
      totalPages: 1,
      currentPage: 1,
      pageSize: list.length,
    );
    return state.copyWith(
        attributes: updated, selectedAttribute: databaseModel);
  }
}

class AttributeRemoveAction extends ReduxAction<AppState> {
  final AttributeModel model;

  AttributeRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().attributeApi.remove(model);
    final List<AttributeModel> attributes =
        List.of(state.attributes.items, growable: true);
    attributes.remove(model);
    final AttributeModel? selectedModel =
        state.selectedAttribute.hashCode == model.hashCode
            ? null
            : state.selectedAttribute;
    final updated = state.attributes.copyWith(
      items: attributes,
      totalItems: attributes.length,
      totalPages: 1,
      currentPage: 1,
      pageSize: attributes.length,
    );
    return state.copyWith(
        attributes: updated, selectedAttribute: selectedModel);
  }
}

class AttributeDatabaseUpdate extends ReduxAction<AppState> {

  AttributeDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedAttribute == null) return null;
    final AttributeModel selected = state.selectedAttribute!;
    final AttributeModel dbModel = await ApiService().attributeApi.update(selected);
    final List<AttributeModel> models = List.of(state.attributes.items, growable: true);
    final int index = models.indexWhere((element) => element.id == selected.id);
    models.removeAt(index);
    models.insert(index, dbModel);
    final updated = state.attributes.copyWith(
      items: models,
      totalItems: models.length,
      totalPages: state.attributes.totalPages,
      currentPage: state.attributes.currentPage,
      pageSize: models.length,
    );
    return state.copyWith(attributes: updated, selectedAttribute: dbModel);
  }
}
