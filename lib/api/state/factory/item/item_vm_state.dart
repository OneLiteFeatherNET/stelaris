import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/item/item_page.dart';

class ItemVmFactory extends VmFactory<AppState, ItemPage, ItemViewModel> {

  ItemVmFactory();

  @override
  ItemViewModel fromStore() =>
      ItemViewModel(itemModels: state.items, selected: state.selectedItem);
}

class ItemViewModel extends Vm {

  final List<ItemModel> itemModels;
  final ItemModel? selected;

  ItemViewModel({required this.itemModels, required this.selected,})
      : super(equals: [itemModels, selected]);

  bool isSelectedItem(ItemModel model) {
    if (selected == null) return false;

    final selectedModel = selected!;

    if (selectedModel.id != null && model.id != null) {
      return selectedModel.id == model.id;
    }
    return selectedModel.hashCode == model.hashCode;
  }
}