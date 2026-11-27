import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item/item_lore_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/item/lore/lore_page.dart';

class ItemLoreViewFactory extends VmFactory<AppState, LorePage, ItemLoreView> {
  ItemLoreViewFactory();

  @override
  fromStore() => ItemLoreView(
    selected: state.selectedItem!,
    isLoadingMore: isWaiting(ItemLoreLoadNextPageAction),
  );
}

class ItemLoreView extends Vm {
  ItemLoreView({required this.selected, required this.isLoadingMore})
    : super(equals: [selected, isLoadingMore]);

  final ItemModel selected;

  /// Whether the next page of lore lines is loading.
  final bool isLoadingMore;

  PaginatedResult<ItemLoreDto> get loreLines => selected.lore;

  List<ItemLoreDto> get items => selected.lore.items;
}
