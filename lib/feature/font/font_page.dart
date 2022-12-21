import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/state/actions/font_actions.dart';
import 'package:stelaris_ui/api/util/minecraft/font_type.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';
import 'package:stelaris_ui/feature/dialogs/stepper/item_stepper.dart';

import '../../api/state/app_state.dart';
import '../../api/tabs/tab_pages.dart';

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
        if (store.state.blocks.isEmpty) {
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
            return Text("Blob");
            },
          openFunction: () {
            showDialog(
                context: context,
                useRootNavigator: false,
                builder: (BuildContext context) {
                  return ItemStepper(
                      finishCallback: (model) {
                        StoreProvider.dispatch(context, InitFontAction());
                        Navigator.pop(context);
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
    switch(e) {
      case TabPages.general:
        return getOneIndex(test.value);
      case TabPages.meta:
        return getOneIndex(test.value);
    }
  }

  Widget getOneIndex(model) {
    return Wrap(
      children: [
        createInputContainer("Name", model?.name),
        createDropDownContainer(
            String,
            "Type",
            model?.type,
            FontType.bitmap.toString(),
            items
        ),
        createTypedInputContainer(
            "Ascent",
            model?.ascent?.toString(),
            const TextInputType.numberWithOptions(signed: true),
            null
        ),
        createTypedInputContainer(
            "Height",
            model?.height?.toString(),
            const TextInputType.numberWithOptions(signed: true),
            null
        )
      ],
    );
  }
}

List<DropdownMenuItem<String>> getItems() {
  List<FontType> values = FontType.values;
  return List.generate(values.length, (index) =>
      DropdownMenuItem(
        value: values[index].displayName,
        child: Text(values[index].displayName),
      )
  );
}