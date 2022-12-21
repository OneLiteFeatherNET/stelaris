import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/block_model.dart';
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
        if (store.state.blocks.isEmpty) {
          store.dispatch(InitBlockAction());
        }
      },
      converter: (store) {
        return store.state.blocks;
      },
      builder: (context, vm) {
        selectedItem.value ??= vm.first;
        return ModelContainerList<BlockModel>(
          mapToDeleteDialog: (value) {
            return [
              const TextSpan(
                  text: "Will you delete ",
                  style: TextStyle(color: Colors.white)),
              TextSpan(
                  text: value.name ?? "Unknown",
                  style: const TextStyle(color: Colors.red))
            ];
          },
          mapToDeleteSuccessfully: (value) {
            StoreProvider.dispatch(context, RemoveBlockAction(value));
            return true;
          },
          selectedItem: selectedItem,
          items: vm,
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

  Widget mapPageToWidget(TabPages e, ValueNotifier<BlockModel?> test) {
    switch(e) {
      case TabPages.general:
        return ValueListenableBuilder<BlockModel?>(valueListenable: test, builder: (BuildContext context, BlockModel? value, Widget? child) {
          return getGeneralContent(value);
        });
      case TabPages.meta:
        return nil;
    }
  }

  Widget getGeneralContent(BlockModel? model) {
    if (model == null) {
      return nil;
    }

    return Wrap(
      children: [
        createInputContainer("Name", model.name),
        createInputContainer("ModelData", model.modelData.toString())
      ],
    );
  }
}