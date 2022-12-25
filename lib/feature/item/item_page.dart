import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_data_card.dart';
import 'package:stelaris_ui/feature/base/cards/text_input_card.dart';
import 'package:stelaris_ui/feature/dialogs/dismiss_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/enum_add_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/item_enchantments_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/item_flag_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/stepper/setup_stepper.dart';
import 'package:stelaris_ui/util/constants.dart';

import '../../api/state/app_state.dart';
import '../../api/util/minecraft/item_flag.dart';
import '../base/model_container_list.dart';

const List<ItemFlag> flags = ItemFlag.values;
List<DropdownMenuItem<ItemFlag>> items = List.generate(
    flags.length,
    (index) => DropdownMenuItem(
          value: flags[index],
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
                    text: firstLine,
                    style: TextStyle(color: Colors.white)),
                TextSpan(
                    text: value.name ?? unknownEntry,
                    style: const TextStyle(color: Colors.red)),
                const TextSpan(
                    text: secondLine,
                    style: TextStyle(color: Colors.white)),
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
            TextInputCard<String>(
                title: const Text("Name"),
                currentValue: model.name ?? empty,
                valueUpdate: (value) {
                  if (value == model.name) return;
                  final oldModel = model;
                  final newEntry = oldModel.copyWith(name: value);
                  setState(() {
                    StoreProvider.dispatch(context, UpdateItemAction(oldModel, newEntry));
                    selectedItem.value = newEntry;
                  });
              },
            ),
            TextInputCard<String>(
              title: const Text("Description"),
              currentValue: model.description ?? empty,
              valueUpdate: (value) {
                if (value == model.description) return;
                final oldModel = model;
                final newEntry = oldModel.copyWith(description: value);
                setState(() {
                  StoreProvider.dispatch(context, UpdateItemAction(oldModel, newEntry));
                  selectedItem.value = newEntry;
                });
              },
            ),
            TextInputCard<String>(
              title: const Text("Material"),
              currentValue: model.material ?? empty,
              valueUpdate: (value) {
                if (value == model.material) return;
                final oldModel = model;
                final newEntry = oldModel.copyWith(material: value);
                setState(() {
                  StoreProvider.dispatch(context, UpdateItemAction(oldModel, newEntry));
                  selectedItem.value = newEntry;
                });
              },
            ),
            TextInputCard<String>(
              title: const Text("Displayname"),
              currentValue: model.displayName ?? empty,
              valueUpdate: (value) {
                if (value == model.displayName) return;
                final oldModel = model;
                final newEntry = oldModel.copyWith(displayName: value);
                setState(() {
                  StoreProvider.dispatch(context, UpdateItemAction(oldModel, newEntry));
                  selectedItem.value = newEntry;
                });
              },
            ),
            TextInputCard(
                title: const Text("ModelData"),
                currentValue: model.customModelId?.toString() ?? zero,
                valueUpdate: (value) {
                  if (value == model.customModelId) return;
                  final oldModel = model;
                  final newID = int.parse(value);
                  final newEntry = oldModel.copyWith(customModelId: newID);
                  setState(() {
                    StoreProvider.dispatch(context, UpdateItemAction(oldModel, newEntry));
                    selectedItem.value = newEntry;
                  });
                },
                inputType: numberInput,
                formatter: [FilteringTextInputFormatter.allow(numberPattern)],
            ),
            TextInputCard(
              title: const Text("Amount"),
              currentValue: model.amount?.toString() ?? zero,
              valueUpdate: (value) {
                if (value == model.amount) return;
                final oldModel = model;
                final newAmount = int.parse(value);
                final newEntry = oldModel.copyWith(amount: newAmount);
                setState(() {
                  StoreProvider.dispatch(context, UpdateItemAction(oldModel, newEntry));
                  selectedItem.value = newEntry;
                });
              },
              inputType: numberInput,
              formatter: [FilteringTextInputFormatter.allow(numberPattern)],
            ),
          ],
        ),
        Positioned(
            bottom: 25,
            right: 25,
            child: FloatingActionButton.extended(
              heroTag: UniqueKey(),
              onPressed: () {
                ApiService().itemApi.update(model);
              },
              label: saveText,
              icon: saveIcon,
            ))
      ],
    );
  }

  Widget getMetaContent(ItemModel? model) {
    if (model == null) {
      return nil;
    }
    final List<String> flags = model.flags!.toList();
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
                    return EnumAddDialog<ItemFlag>(
                      title: const Text("Add a flag", textAlign: TextAlign.center),
                      items: items,
                      valueUpdate: (value) {
                        final oldEntry = model;
                        Set<String> flags = Set.of(oldEntry.flags ?? {});
                        flags.add(value!.minestomValue);
                        final newEntry = oldEntry.copyWith(flags: flags);
                        setState(() {
                          StoreProvider.dispatch(context, UpdateItemAction(oldEntry, newEntry));
                          Navigator.pop(context);
                          selectedItem.value = newEntry;
                        });
                      }
                    );
                  },
                );
              },
              widgets: List<Widget>.generate(flags.length, (index) {
                final key = flags[index];
                return ListTile(
                  title: Text(key),
                  trailing: IconButton(
                    icon: deleteIcon,
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return DeleteDialog(
                                title: deleteTitle,
                                header: [
                                  const TextSpan(
                                      text: firstLine,
                                      style: TextStyle(color: Colors.white)),
                                  TextSpan(
                                      text: key,
                                      style: const TextStyle(color: Colors.red)),
                                  const TextSpan(
                                      text: secondLine,
                                      style: TextStyle(color: Colors.white)),
                                ],
                                context: context,
                                value: key,
                                successfully: (value) {
                                  final oldEntry = model;
                                  Set<String> oldFlags = Set.of(oldEntry.flags ?? {});
                                  oldFlags.remove(key);
                                  final newEntry = oldEntry.copyWith(flags: oldFlags);
                                  setState(() {
                                    StoreProvider.dispatch(context, UpdateItemAction(oldEntry, newEntry));
                                    selectedItem.value = newEntry;
                                  });
                                  return true;
                                }
                            ).getDeleteDialog();
                          });
                    },
                  ),
                );

              })
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
                        showDialog(
                            context: context,
                            builder: (context) {
                              return DeleteDialog(
                                  title: deleteTitle,
                                  header:  [
                                    const TextSpan(
                                        text: firstLine,
                                        style: TextStyle(color: Colors.white)),
                                    TextSpan(
                                        text: key,
                                        style: const TextStyle(color: Colors.red)),
                                    const TextSpan(
                                        text: secondLine,
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                  context: context,
                                  value: key,
                                  successfully: (value) {
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
                                    return true;
                                  }
                              ).getDeleteDialog();
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
                        controller: TextEditingController(),
                        valueUpdate: ((value) {
                          final oldEntry = model;
                          List<String> oldLores = List.of(oldEntry.lore ?? []);
                          oldLores.add(value);
                          final newEntry = oldEntry.copyWith(lore: oldLores);
                          setState(() {
                            StoreProvider.dispatch(context, UpdateItemAction(oldEntry, newEntry));
                            Navigator.pop(context);
                            selectedItem.value = newEntry;
                          });
                        }),
                        title: const Text("Add new line")
                    );
                  },
                );
              },
              widgets: List<Widget>.generate(model.lore?.length ?? 0, (index) {
                final key = model.lore?[index];
                return ListTile(
                  title: Text(key!),
                  trailing: IconButton(
                    icon: deleteIcon,
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return DeleteDialog(
                                title: deleteTitle,
                                header:  [
                                  const TextSpan(
                                      text: firstLine,
                                      style: TextStyle(color: Colors.white)),
                                  TextSpan(
                                      text: key,
                                      style: const TextStyle(color: Colors.red)),
                                  const TextSpan(
                                      text: secondLine,
                                      style: TextStyle(color: Colors.white)),
                                ],
                                context: context,
                                value: key,
                                successfully: (value) {
                                  final oldEntry = model;
                                  List<String> oldLores = List.of(oldEntry.lore ?? []);
                                  oldLores.remove(key);
                                  final newEntry = oldEntry.copyWith(lore: oldLores);
                                  setState(() {
                                    StoreProvider.dispatch(context, UpdateItemAction(oldEntry, newEntry));
                                    selectedItem.value = newEntry;
                                  });
                                  return true;
                                }
                            ).getDeleteDialog();
                          });
                    },
                  ),
                );
              }),
            ),
          ],

        ),
        Positioned(
            bottom: 25,
            right: 25,
            child: FloatingActionButton.extended(
              heroTag: UniqueKey(),
              onPressed: () {
                ApiService().itemApi.update(model);
              },
              label: saveText,
              icon: saveIcon,
            )
        )
      ],
    );
  }
}
