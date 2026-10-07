import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/item/components/item_components_page.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_page.dart';
import 'package:stelaris/feature/item/lore/lore_page.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/feature/model/model_detail_tab_bar.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The detail view reached by tapping an item card in [ItemPage].
///
/// Shows the shared [ModelDetailShell] header row with its actions, with a `TabBar`/
/// `TabBarView` (Components/Enchantments/Lore) below it as the body. Each tab
/// renders one of [ItemComponentsPage]/[ItemEnchantmentPage]/[LorePage],
/// which read the selected item from Redux themselves.
class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({super.key});

  /// The tabs in order. Their ids are what `?tab=` and the command palette
  /// refer to.
  static final List<DetailTab> tabs = [
    DetailTab('components', (l10n) => l10n.tab_components),
    // General (formerly Meta) only held the group, which moved next to the
    // enchantments it decides.
    DetailTab(
      'enchantments',
      (l10n) => l10n.tab_enchantments,
      formerIds: ['general', 'meta'],
    ),
    DetailTab('lore', (l10n) => l10n.tab_lore),
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
            readNotes: (model) => model.comment,
          ),
        ],
        body: DefaultTabController(
          // Keyed by the requested tab: a new ?tab= on the same route has to
          // start a new controller, or the old tab would stay selected.
          key: ValueKey(requestedTab(context)),
          initialIndex: initialTabIndex(context, tabs),
          length: tabs.length,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModelDetailTabBar(
                tabs: [
                  for (final tab in tabs) Tab(text: tab.label(context.l10n)),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    ItemComponentsPage(),
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

class _ItemDetailFactory
    extends VmFactory<AppState, ItemDetailPage, _ItemDetailView> {
  @override
  _ItemDetailView fromStore() =>
      _ItemDetailView(title: state.selectedItem?.uiName);
}
