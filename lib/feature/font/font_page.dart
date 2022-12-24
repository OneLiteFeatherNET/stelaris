import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/state/actions/font_actions.dart';
import 'package:stelaris_ui/api/util/minecraft/font_type.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/cards/text_input_card.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';
import 'package:stelaris_ui/feature/dialogs/item_flag_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/stepper/setup_stepper.dart';
import 'package:stelaris_ui/util/constants.dart';

import '../../api/state/app_state.dart';
import '../../api/tabs/tab_pages.dart';
import '../base/cards/expandable_data_card.dart';

const List<FontType> values = FontType.values;
List<DropdownMenuItem<String>> items = getItems();

class FontPage extends StatefulWidget {
  const FontPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FontPageState();
  }
}

class FontPageState extends State<FontPage> with BaseLayout {
  final ValueNotifier<FontModel?> selectedItem = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<FontModel>>(
      onInit: (store) {
        if (store.state.fonts.isEmpty) {
          store.dispatch(InitFontAction());
        }
      },
      converter: (store) {
        return store.state.fonts;
      },
      builder: (context, vm) {
        selectedItem.value ??= vm.first;
        return ModelContainerList<FontModel>(
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
            StoreProvider.dispatch(context, RemoveFontsAction(value));
            return true;
          },
          selectedItem: selectedItem,
          items: vm,
          page: mapPageToWidget,
          mapToDataModelItem: (e) {
            return Text(e.name?? "Unknown");
          },
          openFunction: () {
            showDialog(
                context: context,
                useRootNavigator: false,
                builder: (BuildContext context) {
                  return SetupStepper<FontModel>(
                      buildModel: (name, description) {
                    return FontModel(name: name, type: FontType.bitmap.displayName);
                  }, finishCallback: (model) {
                    StoreProvider.dispatch(context, InitFontAction());
                    Navigator.pop(context);
                    selectedItem.value = model;
                  });
                });
          },
        );
      },
    );
  }

  Widget mapDataToModelItem(FontModel model) {
    return Text(model.name ?? "Test");
  }

  Widget mapPageToWidget(TabPages e, ValueNotifier<FontModel?> test) {
    switch (e) {
      case TabPages.general:
        return ValueListenableBuilder<FontModel?>(
            valueListenable: test,
            builder: (BuildContext context, FontModel? value, Widget? child) {
              return getGeneralContent(value);
            });
      case TabPages.meta:
        return ValueListenableBuilder<FontModel?>(
            valueListenable: test,
            builder: (BuildContext context, FontModel? value, Widget? child) {
              return getMetaContent(value);
            });
    }
  }

  Widget getGeneralContent(FontModel? model) {
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
              formatter: [FilteringTextInputFormatter.allow(stringPattern)],
              valueUpdate: (value) {
                if (value == model.name) return;
                final oldModel = model;
                final newEntry = oldModel.copyWith(name: value);
                setState(() {
                  StoreProvider.dispatch(context, UpdateFontAction(oldModel, newEntry));
                  selectedItem.value = newEntry;
                });
              },
            ),
            TextInputCard<String>(
              title: const Text("Description"),
              currentValue: model.description ?? empty,
              formatter: [FilteringTextInputFormatter.allow(stringPattern)],
              valueUpdate: (value) {
                if (value == model.description) return;
                final oldModel = model;
                final newEntry = oldModel.copyWith(description: value);
                setState(() {
                  StoreProvider.dispatch(context, UpdateFontAction(oldModel, newEntry));
                  selectedItem.value = newEntry;
                });
              },
            ),
            createDropDownContainer(
                String, "Type", model.type, FontType.bitmap.displayName, items),
            TextInputCard<String>(
              title: const Text("Ascent"),
              currentValue: model.ascent?.toString() ?? zero,
              valueUpdate: (value) {},
              inputType: numberInput,
              formatter: [FilteringTextInputFormatter.allow(numberPattern)],
            ),
            TextInputCard(
                title: const Text("Height"),
                currentValue: model.height?.toString() ?? zero,
                valueUpdate: (value) {},
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
              onPressed: () {},
              label: const Text("Save"),
              icon: const Icon(Icons.save),
            )
        )
      ],
    );
  }

  Widget getMetaContent(FontModel? model) {
    if (model == null) return nil;

    return Stack(
      children: [
        Wrap(
          clipBehavior: Clip.hardEdge,
          children: [
            ExpandableDataCard(
                title: const Text("Chars"),
                buttonClick: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return EntryAddDialog(
                          title: const Text("Add new char"),
                          controller: TextEditingController(),
                          valueUpdate: (value) {
                            final oldEntry = model;
                            List<String> chars = List.of(oldEntry.chars ?? []);
                            chars.add(value);
                            final newEntry = oldEntry.copyWith(chars: chars);
                            setState(() {
                              StoreProvider.dispatch(context, UpdateFontAction(oldEntry, newEntry));
                              Navigator.pop(context);
                              selectedItem.value = newEntry;
                            });
                          }
                      );
                    },
                  );
                },
                widgets: List<Widget>.generate(model.chars?.length ?? 0, (index) {
                  final key = model.chars![index];
                  return ListTile(
                    title: Text(key),
                    trailing: IconButton(
                      icon: deleteIcon,
                      onPressed: () {
                        final oldEntry = model;
                        List<String> chars = List.of(model.chars ?? []);
                        chars.remove(key);
                        final newEntry = oldEntry.copyWith(chars: chars);
                        setState(() {
                          StoreProvider.dispatch(
                              context, UpdateFontAction(oldEntry, newEntry));
                          selectedItem.value = newEntry;
                        });
                      },
                    ),
                  );
                })
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
}

List<DropdownMenuItem<String>> getItems() {
  List<FontType> values = FontType.values;
  return List.generate(
      values.length,
      (index) => DropdownMenuItem(
            value: values[index].displayName,
            child: Text(values[index].displayName),
          ));
}
