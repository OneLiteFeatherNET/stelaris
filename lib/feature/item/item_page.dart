import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_data_card.dart';
import 'package:stelaris_ui/feature/dialogs/item_enchantments_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/item_flag_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/stepper/setup_stepper.dart';
import 'package:stelaris_ui/util/constants.dart';

import '../../api/state/app_state.dart';
import '../../api/util/minecraft/item_flag.dart';
import '../base/model_container_list.dart';

const List<ItemFlag> flags = ItemFlag.values;
List<DropdownMenuItem<String>> items = List.generate(
    flags.length,
    (index) => DropdownMenuItem(
          value: flags[index].display,
          child: Text(flags[index].display),
        ));

class ItemPage extends StatefulWidget {
  const ItemPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ItemPageState();
  }
}

class ItemPageState extends State<ItemPage> with BaseLayout {
  final ValueNotifier<ItemModel?> selectedItem = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<ItemModel>>(
      onInit: (store) {
        if (store.state.items.isEmpty) {
          store.dispatch(InitItemAction());
        }
      },
      converter: (store) {
        return store.state.items;
      },
      builder: (context, vm) {
        selectedItem.value ??= vm.first;
        return ModelContainerList<ItemModel>(
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
              StoreProvider.dispatch(context, RemoveItemAction(value));
              return true;
            },
            items: vm,
            page: mapPageToWidget,
            mapToDataModelItem: mapDataToModelItem,
            selectedItem: selectedItem,
            openFunction: () {
              showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: Card(
                        child: SetupStepper<ItemModel>(
                          buildModel: (name, description) {
                            return ItemModel(name: name);
                          },
                          finishCallback: (model) {
                            StoreProvider.dispatch(
                                context, AddItemAction(model));
                            Navigator.pop(context);
                            selectedItem.value = model;
                          },
                        ),
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

  Widget mapPageToWidget(TabPages e, ValueNotifier<ItemModel?> listenable) {
    switch (e) {
      case TabPages.general:
        return ValueListenableBuilder<ItemModel?>(
            valueListenable: listenable,
            builder: (BuildContext context, ItemModel? value, Widget? child) {
              return getGeneralContent(value);
            });
      case TabPages.meta:
        return ValueListenableBuilder<ItemModel?>(
            valueListenable: listenable,
            builder: (BuildContext context, value, Widget? child) {
              return getMetaContent(value);
            });
    }
  }

  Widget getGeneralContent(ItemModel? model) {
    if (model == null) {
      return nil;
    }
    return Stack(
      children: [
        Wrap(
          children: [
            createInputContainer("Name", model.name),
            createInputContainer("Material", model.material),
            createTypedInputContainer(
                "ModelData",
                model.modelData?.toString(),
                const TextInputType.numberWithOptions(signed: true),
                null),
            createTypedInputContainer("Amount", model.amount?.toString(),
                const TextInputType.numberWithOptions(signed: true), null),
          ],
        ),
        Positioned(
            bottom: 25,
            right: 25,
            child: FloatingActionButton.extended(
              heroTag: UniqueKey(),
              onPressed: () {},
              label: const Text("Save"),
              icon: const Icon(Icons.save),
            ))
      ],
    );
  }

  Widget getMetaContent(ItemModel? model) {
    if (model == null) {
      return nil;
    }
    return Stack(
      children: [
          Wrap(
          clipBehavior: Clip.hardEdge,
          children: [
            ExpandableDataCard(
              title: const Text("Flags"),
              buttonClick: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return EntryAddDialog(
                      title: const Text(
                        "Add a flag",
                        textAlign: TextAlign.center,
                      ),
                      widget: getItemFlagSelection(),
                    );
                  },
                );
              },
              widgets: model.flags
                  ?.map(
                    (e) => ListTile(
                  title: Text(e),
                  trailing: IconButton(
                    icon: deleteIcon,
                    onPressed: () {},
                  ),
                ),
              )
                  .toList() ??
                  List.empty(),
            ),
            ExpandableDataCard(
              title: const Text("Enchantments"),
              buttonClick: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      final oldEntry = model;
                      return ItemEnchantmentAddDialog(
                        addEnchantmentCallback: (selected, level) {
                          final oldEnchantments =
                          Map<String, int>.of(oldEntry.enchantments ?? {});
                          oldEnchantments[selected.minecraftValue] = level;
                          final newEntry =
                          oldEntry.copyWith(enchantments: oldEnchantments);
                          setState(() {
                            Navigator.pop(context);
                            StoreProvider.dispatch(
                                context, UpdateItemAction(oldEntry, newEntry));
                            selectedItem.value = newEntry;
                          });
                        },
                      );
                    });
              },
              widgets:
              List<Widget>.generate(model.enchantments?.length ?? 0, (index) {
                final key = model.enchantments?.keys.elementAt(index);
                final value = model.enchantments?.values.elementAt(index);
                return ListTile(
                    title: Text("$key, Level: $value"),
                    trailing: IconButton(
                      icon: deleteIcon,
                      onPressed: () {
                        final oldEntry = model;
                        final oldEnchantments =
                        Map<String, int>.of(oldEntry.enchantments ?? {});
                        oldEnchantments.remove(key);
                        final newEntry =
                        oldEntry.copyWith(enchantments: oldEnchantments);
                        setState(() {
                          StoreProvider.dispatch(
                              context, UpdateItemAction(oldEntry, newEntry));
                          selectedItem.value = newEntry;
                        });
                      },
                    ));
              }),
            ),
            ExpandableDataCard(
              title: const Text("Lore"),
              buttonClick: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return EntryAddDialog(
                        title: const Text("Add new line"),
                        widget: TextFormField(keyboardType: TextInputType.text));
                  },
                );
              },
              widgets: model.lore
                  ?.map(
                    (e) => ListTile(
                  title: Text(e),
                  trailing: IconButton(
                    icon: deleteIcon,
                    onPressed: () {},
                  ),
                ),
              )
                  .toList() ??
                  List.empty(),
            ),
          ],

        ),
        Positioned(
            bottom: 25,
            right: 25,
            child: FloatingActionButton.extended(
              heroTag: UniqueKey(),
              onPressed: () {},
              label: const Text("Save"),
              icon: const Icon(Icons.save),
            )
        )
      ],
    );
  }

  Widget getItemFlagSelection() {
    return DropdownButtonFormField(
      value: items[0].value,
      items: items,
      onChanged: (value) {},
    );
  }
}
