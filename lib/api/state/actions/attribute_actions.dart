import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/attribute_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';

class SelectAttributeAction extends ReduxAction<AppState> {

  final AttributeModel model;

  SelectAttributeAction(this.model);

  @override
  AppState reduce() {
    return state.copyWith(selectedAttribute: model);
  }
}

class RemoveSelectAttributeAction extends ReduxAction<AppState> {

  final AttributeModel model;

  RemoveSelectAttributeAction(this.model);

  @override
  AppState? reduce() {
    if (state.selectedAttribute == null) return null;
    return state.copyWith(selectedAttribute: null);
  }
}

class InitAttributeAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    List<AttributeModel> attributes = await ApiService().attributesAPI.getAll();
    if (attributes.isEmpty) return null;
    return state.copyWith(attributes: attributes);
  }
}

class UpdateAttributeAction extends ReduxAction<AppState> {
  final AttributeModel oldEntry;
  final AttributeModel newEntry;

  UpdateAttributeAction(this.oldEntry, this.newEntry,);

  @override
  Future<AppState?> reduce() async {
    final attributes = List.of(state.attributes, growable: true);
    int index = attributes.indexWhere((element) => element.id == oldEntry.id);
    attributes.removeAt(index);
    attributes.insert(index, newEntry);
    return state.copyWith(attributes: attributes, selectedAttribute: newEntry);
  }
}

class AttributeAddAction extends ReduxAction<AppState> {

  final AttributeModel model;

  AttributeAddAction(this.model);

  @override
  Future<AppState?> reduce() async {
    var databaseModel = await ApiService().attributesAPI.add(model);
    var attributes = List.of(state.attributes, growable: true);
    attributes.add(databaseModel);
    return state.copyWith(attributes: attributes, selectedAttribute: databaseModel);
  }
}

class AttributeRemoveAction extends ReduxAction<AppState> {

  final AttributeModel model;

  AttributeRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().attributesAPI.remove(model);
    var attributes = List.of(state.attributes, growable: true);
    attributes.remove(model);
    var selectedModel = state.selectedAttribute.hashCode == model.hashCode ? null : state.selectedAttribute;
    return state.copyWith(attributes: attributes, selectedAttribute: selectedModel);
  }
}