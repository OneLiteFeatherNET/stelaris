import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_page.dart';
import 'package:stelaris/feature/item/general/item_general_page.dart';
import 'package:stelaris/feature/item/lore/lore_page.dart';
import 'package:stelaris/feature/item/meta/item_meta_page.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/feature/model/model_detail_tab_bar.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The detail view reached by tapping an item card in [ItemPage].
///
/// Shows the shared [ModelDetailShell] header row with its actions, with a `TabBar`/
/// `TabBarView` (General/Meta/Enchantments/Lore) below it as the body. Each
/// tab renders one of the existing, unchanged [ItemGeneralPage]/
/// [ItemMetaPage]/[ItemEnchantmentPage]/[LorePage] widgets, which already
/// read the selected item from Redux themselves.
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
    return StoreConnector<AppState, _ItemDetailView>(
      vm: () => _ItemDetailFactory(),
      onDispose: (store) =>
          store.dispatch(RemoveSelectItemAction(), notify: false),
      builder: (context, vm) => ModelDetailShell(
        entry: NavigationEntry.items,
        title: vm.title,
        actions: [
          ModelDetailActions<ItemModel>(
            entry: NavigationEntry.items,
            selectModel: (state) => state.selectedItem,
            nameSelector: (model) => model.uiName,
            keySelector: (model) => model.key ?? '',
            deleteTitle: context.l10n.dialog_item_delete_title,
            deleteWarning: context.l10n.delete_dialog_related_item,
            removeAction: ItemRemoveAction.new,
          ),
        ],
        body: DefaultTabController(
          length: _tabs.length,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModelDetailTabBar(tabs: _tabs),
              Expanded(
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
      ),
    );
  }
}

class _ItemDetailView extends Vm {
  _ItemDetailView({required this.title}) : super(equals: [title]);

  final String? title;
}

class _ItemDetailFactory extends VmFactory<AppState, ItemDetailPage, _ItemDetailView> {
  @override
  _ItemDetailView fromStore() => _ItemDetailView(title: state.selectedItem?.uiName);
}
