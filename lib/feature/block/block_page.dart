import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/block_model.dart';
import 'package:stelaris_ui/api/state/actions/block_actions.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/cards/text_input_card.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';
import 'package:stelaris_ui/feature/dialogs/stepper/setup_stepper.dart';
import 'package:stelaris_ui/util/constants.dart';

import '../../api/state/app_state.dart';
import '../../api/tabs/tab_pages.dart';

class BlockPage extends StatefulWidget {

  const BlockPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BlockPageState();
  }
}

class BlockPageState extends State<BlockPage> with BaseLayout {

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
          openFunction: () {
            showDialog(
                context: context,
                useRootNavigator: false,
                builder: (BuildContext context) {
                  return SetupStepper<BlockModel>(
                      buildModel: (name, description) {
                        return BlockModel(name: name);
                      }, finishCallback: (model) {
                    StoreProvider.dispatch(context, InitBlockAction());
                    Navigator.pop(context);
                    selectedItem.value = model;
                  });
                });
          },
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

    return Stack(
      children: [
        Wrap(
          children: [
            TextInputCard<String>(
              title: const Text("Name"),
              currentValue: model.name ?? "",
              formatter: [FilteringTextInputFormatter.allow(stringPattern)],
              valueUpdate: (value) {
                if (value == model.name) return;
                final oldModel = model;
                final newEntry = oldModel.copyWith(name: value);
                setState(() {
                  StoreProvider.dispatch(context, UpdateBlockAction(oldModel, newEntry));
                  selectedItem.value = newEntry;
                });
              },
            ),
            TextInputCard<String>(
              title: const Text("ModelData"),
              currentValue: model.customModelId.toString(),
              formatter: [FilteringTextInputFormatter.allow(numberPattern)],
              valueUpdate: (value) {
                if (value == model.customModelId) return;
                final oldModel = model;
                final newID = int.parse(value);
                final newEntry = oldModel.copyWith(customModelId: newID);
                setState(() {
                  StoreProvider.dispatch(context, UpdateBlockAction(oldModel, newEntry));
                  selectedItem.value = newEntry;
                });
              },
            ),
          ],
        ),
        Positioned(
            bottom: 25,
            right: 25,
            child: FloatingActionButton.extended(
              heroTag: UniqueKey(),
              onPressed: () {
                ApiService().blockAPI.update(model);
              },
              label: saveText,
              icon: saveIcon,
            )
        )
      ]
    );
  }
}