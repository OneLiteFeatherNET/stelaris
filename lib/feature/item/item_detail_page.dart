import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_page.dart';
import 'package:stelaris/feature/item/general/item_general_page.dart';
import 'package:stelaris/feature/item/lore/lore_page.dart';
import 'package:stelaris/feature/item/meta/item_meta_page.dart';
import 'package:stelaris/feature/model/model_detail_back_bar.dart';

/// The detail view reached by tapping an item card in [ItemPage].
///
/// The back arrow and the tab bar (General/Meta/Enchantments/Lore) share a
/// single row, followed by the unchanged [ItemGeneralPage]/[ItemMetaPage]/
/// [ItemEnchantmentPage]/[LorePage] tab content, which read the selected
/// item from Redux themselves.
class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({super.key});

  static const List<Tab> _tabs = [
    Tab(text: 'General'),
    Tab(text: 'Meta'),
    Tab(text: 'Enchantments'),
    Tab(text: 'Lore'),
  ];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ItemDetailCleanupView>(
      vm: () => _ItemDetailCleanupFactory(),
      onDispose: (store) =>
          store.dispatch(RemoveSelectItemAction(), notify: false),
      builder: (context, vm) => DefaultTabController(
        length: _tabs.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  ModelDetailBackBar(parentRoute: NavigationEntry.items.route),
                  const Expanded(child: TabBar(tabs: _tabs)),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  ItemGeneralPage(),
                  ItemMetaPage(),
                  ItemEnchantmentPage(),
                  LorePage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemDetailCleanupView extends Vm {
  _ItemDetailCleanupView() : super(equals: const []);
}

class _ItemDetailCleanupFactory
    extends VmFactory<AppState, ItemDetailPage, _ItemDetailCleanupView> {
  @override
  _ItemDetailCleanupView fromStore() => _ItemDetailCleanupView();
}
