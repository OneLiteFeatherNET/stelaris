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
    loading: isWaiting(ItemLoreFetchAction),
  );
}

class ItemLoreView extends Vm {
  ItemLoreView({required this.selected, this.loading = false})
    : super(equals: [selected, loading]);

  final ItemModel selected;

  /// The lore of [selected] is being loaded.
  final bool loading;

  bool get isLoadingMore => selected.isLoadingMoreLoreLines;

  PaginatedResult<ItemLoreDto> get loreLines => selected.lore;

  List<ItemLoreDto> get items => selected.lore.items;
}
