import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/attribute_model.dart';

import '../app_state.dart';

class InitAttributeListAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    List<AttributeModel> attributes = await ApiService().attributesAPI.getAll();
    return state.copyWith(attributes: attributes);
  }
}

class UpdateAttributeAction extends ReduxAction<AppState> {
  final AttributeModel newEntry;

  UpdateAttributeAction(this.newEntry);

  @override
  Future<AppState?> reduce() async {
    var updatedModel = await ApiService().attributesAPI.update(newEntry);
    final attributes = List.of(state.attributes, growable: true);
    int index = attributes.indexWhere((element) => element.id == newEntry.id);
    attributes.removeAt(index);
    attributes.insert(index, updatedModel);
    return state.copyWith(attributes: attributes);
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
    return state.copyWith(attributes: attributes);
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
    return state.copyWith(attributes: attributes);
  }
}