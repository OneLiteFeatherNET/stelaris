import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/item/item_page.dart';

class ItemVmFactory extends VmFactory<AppState, ItemPage, ItemViewModel> {
  ItemVmFactory();

  @override
  ItemViewModel fromStore() => ItemViewModel(
    itemModels: state.items.items,
    selected: state.selectedItem,
    hasNextPage: state.items.hasNextPage,
    isLoadingMore: state.isLoadingMoreItems,
  );
}

class ItemViewModel extends Vm {
  final List<ItemModel> itemModels;
  final ItemModel? selected;
  final bool hasNextPage;
  final bool isLoadingMore;

  ItemViewModel({
    required this.itemModels,
    required this.selected,
    required this.hasNextPage,
    required this.isLoadingMore,
  }) : super(equals: [itemModels, selected, hasNextPage, isLoadingMore]);

  bool isSelectedItem(ItemModel model) {
    if (selected == null) return false;

    final selectedModel = selected!;

    if (selectedModel.id != null && model.id != null) {
      return selectedModel.id == model.id;
    }
    return selectedModel.hashCode == model.hashCode;
  }
}
