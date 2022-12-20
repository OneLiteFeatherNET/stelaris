import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/block_model.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/api/state/actions/block_actions.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';

import '../../api/state/app_state.dart';
import '../../api/tabs/tab_pages.dart';

class BlockList extends StatefulWidget {

  const BlockList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BlockListState();
  }
}

class BlockListState extends State<BlockList> with BaseLayout {

  final ValueNotifier<BlockModel?> selectedItem = ValueNotifier(null);

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
        var blocKModel = const BlockModel(
            name: "Test",
            generator: "ItemGenerator",
            modelData: 1,
            amount: 1
        );
        var blocks = vm.isNotEmpty ? vm : [blocKModel];
        return ModelContainerList<BlockModel>(
          mapToDeleteDialog: (value) {
            return [];
          },
          mapToDeleteSuccessfully: (value) => true,
          selectedItem: selectedItem,
          items: blocks,
          page: mapPageToWidget,
          mapToDataModelItem: mapDataToModelItem,
          openFunction: () {},
        );
      },
    );
  }

  Widget mapDataToModelItem(BlockModel model) {
    return Text(model.name ?? "Test");
  }

  Widget mapPageToWidget(TabPages e, ValueNotifier<DataModel?> test) {
    switch(e) {
      case TabPages.general:
        return nil;
      case TabPages.meta:
        return nil;
    }
  }
}