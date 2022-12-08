import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';

import '../../api/state/app_state.dart';
import '../base/model_container_list.dart';

class ItemPage extends StatefulWidget {

  const ItemPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ItemPageState();
  }
}

class ItemPageState extends State<ItemPage> with BaseLayout {

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<ItemModel>>(
      onInit: (store) {
        store.dispatch(InitItemAction());
      },
      converter: (store) {
        return store.state.items;
      },
      builder: (context, vm) {
        var model = const ItemModel(
            name: "Test1234",
            generator: "ItemGenerator",
            group: "Test",
            material: "minecraft:air",
            modelData: 1,
            amount: 1);
        List<ItemModel> items = vm.isNotEmpty ? vm : [model];
        return ModelContainerList<ItemModel>(items: items, page: mapPageToWidget, mapToDataModelItem: mapDataToModelItem);
      },
    );
  }

  Widget mapDataToModelItem(ItemModel model) {
    return Text(model.name ?? "Test");
  }
  
  Widget mapPageToWidget<ItemModel>(TabPages e, ValueNotifier<ItemModel?> listenable) {
    switch(e) {
      case TabPages.general:
        return ValueListenableBuilder(valueListenable: listenable, builder: (BuildContext context,value, Widget? child) {
          return getGeneralContent(value);
        });
      case TabPages.additional:
        return Container( padding: const EdgeInsets.only(top: 100), child: const Text("Nothing to see here"));
      case TabPages.meta:
        return ValueListenableBuilder(valueListenable: listenable, builder: (BuildContext context,value, Widget? child) {
          return getMetaContent(value);
        });
    }
  }

  Widget getGeneralContent(model) {
    return Wrap(
      children: [
        createInputContainer("Name", model?.name),
        createInputContainer("Material", model?.material),
        createTypedInputContainer(
            "ModelData",
            model?.modelData?.toString(),
            const TextInputType.numberWithOptions(signed: true),
            null
        )
      ],
    );
  }

  Widget getMetaContent(model) {
    return Wrap(
      children: [
        createTypedInputContainer(
            "Amount",
            model?.amount,
            const TextInputType.numberWithOptions(signed: true),
            null
        ),
      ],
    );
  }
}
