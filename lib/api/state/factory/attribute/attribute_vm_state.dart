import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/model/attribute_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/attributes/attribute_page.dart';

class AttributeVmFactory
    extends VmFactory<AppState, AttributePage, AttributeViewModel> {
  AttributeVmFactory();

  @override
  AttributeViewModel fromStore() => AttributeViewModel(
      models: state.attributes, selected: state.selectedAttribute);
}

class AttributeViewModel extends Vm {
  final List<AttributeModel> models;
  final AttributeModel? selected;

  AttributeViewModel({
    required this.models,
    required this.selected,
  }) : super(equals: [models, selected]);

  bool isSelectedItem(AttributeModel model) {
    if (selected == null) return false;

    final selectedModel = selected!;

    if (selectedModel.id != null && model.id != null) {
      return selectedModel.id == model.id;
    }
    return selectedModel.hashCode == model.hashCode;
  }
}
