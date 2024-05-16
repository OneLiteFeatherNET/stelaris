import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/attribute_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';

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
    final List<AttributeModel> attributes =
        await ApiService().attributesAPI.getAll();
    if (attributes.isEmpty) return null;
    return state.copyWith(attributes: attributes);
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
        await ApiService().attributesAPI.add(model);
    final List<AttributeModel> attributes =
        List.of(state.attributes, growable: true);
    attributes.add(databaseModel);
    return state.copyWith(
        attributes: attributes, selectedAttribute: databaseModel);
  }
}

class AttributeRemoveAction extends ReduxAction<AppState> {
  final AttributeModel model;

  AttributeRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().attributesAPI.remove(model);
    final List<AttributeModel> attributes =
        List.of(state.attributes, growable: true);
    attributes.remove(model);
    final AttributeModel? selectedModel =
        state.selectedAttribute.hashCode == model.hashCode
            ? null
            : state.selectedAttribute;
    return state.copyWith(
        attributes: attributes, selectedAttribute: selectedModel);
  }
}

class AttributeDatabaseUpdate extends ReduxAction<AppState> {

  AttributeDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedAttribute == null) return null;
    final AttributeModel selected = state.selectedAttribute!;
    final AttributeModel dbModel = await ApiService().attributesAPI.update(selected);
    final List<AttributeModel> models = List.of(state.attributes, growable: true);
    final int index = models.indexWhere((element) => element.id == selected.id);
    models.removeAt(index);
    models.insert(index, dbModel);
    return state.copyWith(attributes: models, selectedAttribute: dbModel);
  }
}
