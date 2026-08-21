import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/item/lore/lore_page.dart';

class ItemLoreViewFactory extends VmFactory<AppState, LorePage, ItemLoreView> {
  ItemLoreViewFactory();

  @override
  fromStore() => ItemLoreView(selected: state.selectedItem!);
}

class ItemLoreView extends Vm {
  ItemLoreView({required this.selected}) : super(equals: [selected]);

  final ItemModel selected;

  bool get isLoadingMore => selected.isLoadingMoreLoreLines;

  PaginatedResult<ItemLoreDto> get loreLines => selected.lore;
}
