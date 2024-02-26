import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/model/attribute_model.dart';
import 'package:stelaris_ui/api/state/actions/attribute_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/attributes/attribute_page.dart';

class AttributeVmFactory
    extends VmFactory<AppState, AttributePage, AttributeViewModel> {
  AttributeVmFactory();

  Future<void> updateSelectedEntry(AttributeModel model) async {
    dispatchAsync(SelectAttributeAction(model));
  }

  Future<void> removeSelectedEntry(AttributeModel model) async {
    dispatchAsync(RemoveSelectAttributeAction(model));
  }

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
