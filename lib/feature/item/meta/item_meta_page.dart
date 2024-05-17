import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/state/factory/item/selected_item_state.dart';
import 'package:stelaris_ui/feature/item/meta/enchantment_card.dart';
import 'package:stelaris_ui/feature/item/meta/flag_grid.dart';
import 'package:stelaris_ui/util/constants.dart';

class ItemMetaPage extends StatefulWidget {

  const ItemMetaPage({
    super.key,
  });

  @override
  State<ItemMetaPage> createState() => _ItemMetaPageState();
}

class _ItemMetaPageState extends State<ItemMetaPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedItemView>(
        vm: () => SelectedItemFactory<ItemMetaPage>(),
        builder: (context, vm) {
          return  Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                TabBar.secondary(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'ItemFlags',),
                    Tab(text: 'Enchantments',),
                  ],
                ),
                heightTen,
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      const FlagGrid(),
                      EnchantmentCard(model: vm.selected),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
    );
  }
}
