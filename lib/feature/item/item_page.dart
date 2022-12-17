import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/dialogs/stepper/item_stepper.dart';

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
            amount: 1,
            flags: {"YOLO", "YOLO2", "YOLO3"},
            enchantments:  {'yolo':1, "yolo2": 2, "yolor3": 33},
            lore: ["Test", "This is another line"]
        );
        List<ItemModel> items = vm.isNotEmpty ? vm : [model];
        return ModelContainerList<ItemModel>(
            items: items,
            page: mapPageToWidget,
            mapToDataModelItem: mapDataToModelItem,
            openFunction: () {
              showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: Card(
                        child: ItemStepper(finishCallback: (model) {
                          StoreProvider.dispatch(context, InitItemAction());
                          Navigator.pop(context);
                        }),
                      ),
                    );
                  });
            });
      },
    );
  }

  Widget mapDataToModelItem(ItemModel model) {
    return Text(
      model.name ?? "Test",
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget mapPageToWidget<ItemModel>(
      TabPages e, ValueNotifier<ItemModel?> listenable) {
    switch (e) {
      case TabPages.general:
        return ValueListenableBuilder(
            valueListenable: listenable,
            builder: (BuildContext context, value, Widget? child) {
              return getGeneralContent(value);
            });
      case TabPages.additional:
        return Container(
            padding: const EdgeInsets.only(top: 100),
            child: const Text("Nothing to see here"));
      case TabPages.meta:
        return ValueListenableBuilder(
            valueListenable: listenable,
            builder: (BuildContext context, value, Widget? child) {
              return getMetaContent(value);
            });
    }
  }

  Widget getGeneralContent(model) {
    if (model is ItemModel) {
      return Wrap(
        children: [
          createInputContainer("Name", model.name),
          createInputContainer("Material", model.material),
          createTypedInputContainer("ModelData", model.modelData?.toString(),
              const TextInputType.numberWithOptions(signed: true), null),
          createTypedInputContainer("Amount", model.amount.toString(),
              const TextInputType.numberWithOptions(signed: true), null),
        ],
      );
    }
    return Container();
  }

  Widget getMetaContent(model) {
    if (model is ItemModel) {
      return Wrap(
        clipBehavior: Clip.hardEdge,
        children: [
          createExpansionContainer("Item Flags", IconButton(icon: Icon(Icons.add), onPressed: () {}),
              model.flags?.map((e) => ListTile(title: Text(e), trailing: IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), onPressed: () {},),)).toList() ?? List.empty()),
          createExpansionContainer("Enchantments", IconButton(icon: Icon(Icons.add), onPressed: () {}),
            model.enchantments?.entries.map((e) => ListTile(title: Text("${e.key}, Level: ${e.value}"), trailing: IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), onPressed: () {},),)).toList() ?? List.empty()),
          createExpansionContainer("Lore", IconButton(icon: Icon(Icons.add), onPressed: () {}),
              model.lore?.map((e) => ListTile(title: Text(e), trailing: IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), onPressed: () {},),)).toList() ?? List.empty())
        ],
      );
    }
    return Container();
  }
}
