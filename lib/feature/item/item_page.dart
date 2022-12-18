import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_data_card.dart';
import 'package:stelaris_ui/feature/dialogs/item_enchantments_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/item_flag_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/stepper/item_stepper.dart';
import 'package:stelaris_ui/util/constants.dart';

import '../../api/state/app_state.dart';
import '../../api/util/minecraft/item_flag.dart';
import '../base/model_container_list.dart';

const List<ItemFlag> flags = ItemFlag.values;
List<DropdownMenuItem<String>> items =
List.generate(flags.length, (index) =>
    DropdownMenuItem(value: flags[index].display,child: Text(flags[index].display),)
);


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
        return nil;
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
    return nil;
  }

  Widget getMetaContent(model) {
    if (model is ItemModel) {
      return Wrap(
        clipBehavior: Clip.hardEdge,
        children: [
          ExpandableDataCard(title: const Text("Flags"), buttonClick:() {
            showDialog(context: context, builder: (BuildContext context) {
              return EntryAddDialog(title: const Text("Add a flag", textAlign: TextAlign.center,), widget: getItemFlagSelection(),);
            });
          }, widgets: model.flags?.map((e) => ListTile(title: Text(e), trailing: IconButton(icon: deleteIcon, onPressed: () {},),)).toList() ?? List.empty()
          ),
          ExpandableDataCard(title: const Text("Enchantments"), buttonClick:() {
            showDialog(context: context, builder: (BuildContext context) {
              return ItemEnchantmentAddDialog();
            });
          }, widgets: model.enchantments?.entries.map((e) => ListTile(title: Text("${e.key}, Level: ${e.value}"), trailing: IconButton(icon: deleteIcon, onPressed: () {},),)).toList() ?? List.empty()),
          ExpandableDataCard(title: const Text("Lore"), buttonClick: () {
            showDialog(context: context, builder: (BuildContext context) {
              return EntryAddDialog(title: const Text("Add new line"), widget: TextFormField(keyboardType: TextInputType.text));
            });
          }, widgets: model.lore?.map((e) => ListTile(title: Text(e), trailing: IconButton(icon: deleteIcon, onPressed: () {},),)).toList() ?? List.empty())
        ],
      );
    }
    return nil;
  }

  Widget getItemFlagSelection() {
    return DropdownButtonFormField(
      value: items[0].value,
      items: items,
      onChanged: (value) { },
    );
  }
}
