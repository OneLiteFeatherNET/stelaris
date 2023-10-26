import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/model/attribute_model.dart';

import '../app_state.dart';

class InitAttributeListAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    var attributes = <AttributeModel>[
      AttributeModel(modelName: "Strength", name: "", defaultValue: 0, maximumValue: 10),
      AttributeModel(modelName: "Dexterity",  name: "", defaultValue: 0, maximumValue: 10),
      AttributeModel(modelName: "Constitution",name: "", defaultValue: 0, maximumValue: 10),
      AttributeModel(modelName: "Intelligence", name: "",defaultValue: 0, maximumValue: 10),
      AttributeModel(modelName: "Wisdom", name: "",defaultValue: 0, maximumValue: 10),
      AttributeModel(modelName: "Charisma", name: "",defaultValue: 0, maximumValue: 10),
    ];
    return state.copyWith(attributes: attributes);
  }
}

class UpdateAttributeAction extends ReduxAction<AppState> {
  final AttributeModel oldEntry;
  final AttributeModel newEntry;

  UpdateAttributeAction(this.oldEntry, this.newEntry);

  @override
  Future<AppState?> reduce() async {
    final items = List.of(state.attributes, growable: true);
    int index = items.indexWhere((element) => element.modelName == oldEntry.modelName);
    items.removeAt(index);
    items.insert(index, newEntry);
    return state.copyWith(attributes: items);
  }
}

class AttributeAddAction extends ReduxAction<AppState> {

  final AttributeModel model;

  AttributeAddAction(this.model);

  @override
  Future<AppState?> reduce() async {
    var attributes = List.of(state.attributes, growable: true);
    attributes.add(model);
    return state.copyWith(attributes: attributes);
  }
}

class AttributeRemoveAction extends ReduxAction<AppState> {

  final AttributeModel model;

  AttributeRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    var attributes = List.of(state.attributes, growable: true);
    attributes.remove(model);
    return state.copyWith(attributes: attributes);
  }
}