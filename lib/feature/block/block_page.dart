import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/block_model.dart';
import 'package:stelaris_ui/api/state/actions/block_actions.dart';
import 'package:stelaris_ui/feature/base/base_tab_view.dart';

import '../../api/state/app_state.dart';
import '../../util/constants.dart';

class BlockList extends StatefulWidget {

  const BlockList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BlockListState();
  }
}

class BlockListState extends State<BlockList> implements BaseTabView<BlockModel> {

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<BlockModel>>(
      onInit: (store) {
        store.dispatch(InitBlockAction());
      },
      converter: (store) {
        return store.state.blocks;
      },
      builder: (context, vm) {
        var blocks = vm.isNotEmpty
            ? vm.map((e) => e.name ?? 'X').toList()
            : List<String>.generate(1, (index) => "1");
        return Container(

        );
      },
    );
  }

  @override
  List<Widget> getAttributes() {
    throw UnimplementedError();
  }

  @override
  Widget tabBarView(List<Widget> views) {
    return Expanded(
        child: Scaffold(
          body: TabBarView(
            children: views,
          ),
          appBar: AppBar(
            title: appText,
            bottom: getTabBar(),
            toolbarHeight: 0,
          ),
        )
    );
  }

  @override
  TabBar getTabBar() {
    return const TabBar(
        tabs: [
          Tab(
              child: Text("General")
          ),
          Tab(
            child: Text("Metadata"),
          )
      ]
    );
  }
}