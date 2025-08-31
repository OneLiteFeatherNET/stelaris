import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/attribute_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:vulpes_backend_client/vulpes_backend_client.dart';

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
    final List<ResponseAttributeModelDTO> responseAttributes = (await ApiService().attributeApi.getAllAttributes(pageable: Pageable())).data?.asList() ?? List.empty();
    if (responseAttributes.isEmpty) return null;
    final List<AttributeModel> attributes = responseAttributes
        .map((dto) => AttributeModel(
      id: dto.id,
      variableName: dto.variableName,
      uiName: dto.uiName ?? 'No Name',
      defaultValue: dto.defaultValue ?? 0.0,
    ))
        .toList();
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
    final Response<ResponseAttributeModelDTO> response =
    await ApiService().attributeApi.addAttribute(attributeModelDTO: AttributeModelDTO((b) => {
      b?.uiName = model.uiName,
      b.variableName = model.variableName,
      b.defaultValue = model.defaultValue,
      b.maximumValue = model.maximumValue,
    },));
    final ResponseAttributeModelDTO? dto = response.data;
    if (dto == null) return null;
    final AttributeModel databaseModel = AttributeModel(
      id: dto.id,
      variableName: dto.variableName,
      uiName: dto.uiName ?? 'No Name',
      defaultValue: dto.defaultValue ?? 0.0,
    );
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
    await ApiService().attributeApi.deleteAttributeById(model.id ?? '');
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
    final AttributeModel dbModel = await ApiService().attributeApi.update(selected);
    final List<AttributeModel> models = List.of(state.attributes, growable: true);
    final int index = models.indexWhere((element) => element.id == selected.id);
    models.removeAt(index);
    models.insert(index, dbModel);
    return state.copyWith(attributes: models, selectedAttribute: dbModel);
  }
}
