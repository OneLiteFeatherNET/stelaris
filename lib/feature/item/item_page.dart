import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/dialogs/stepper/setup_stepper.dart';
import 'package:stelaris_ui/feature/item/item_general_page.dart';
import 'package:stelaris_ui/feature/item/item_group.dart';
import 'package:stelaris_ui/feature/item/item_meta_page.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

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
  final ValueNotifier<ItemModel?> selectedItem = ValueNotifier(null);

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
        return ModelContainerList<ItemModel>(
          tabPages: (pages) => pages,
          mapToDeleteDialog: (value) {
            return [
              TextSpan(
                  text: context.l10n.delete_dialog_first_line,
                  style: whiteStyle
              ),
              TextSpan(
                  text: value.modelName ?? unknownEntry,
                  style: redStyle
              ),
              TextSpan(
                  text: context.l10n.delete_dialog_entry,
                  style: whiteStyle
              ),
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
                  child: SizedBox(
                    width: 500,
                    height: 350,
                    child: Card(
                      child: SetupStepper<ItemModel>(
                        buildModel: (name, description) {
                          return ItemModel(modelName: name, description: description, group: ItemGroup.misc.display);
                        },
                        finishCallback: (model) {
                          StoreProvider.dispatch(context, AddItemAction(model));
                          Navigator.pop(context);
                          selectedItem.value = model;
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget mapDataToModelItem(ItemModel model) {
    return Text(
      model.modelName ?? unknownEntry,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget mapPageToWidget(TabPage value, ValueNotifier<ItemModel?> listenable) {
    switch (value) {
      case TabPage.general:
        return ValueListenableBuilder<ItemModel?>(
          valueListenable: listenable,
          builder: (BuildContext context, ItemModel? value, Widget? child) {
            if (value == null) return nil;
            return ItemGeneralPage(model: value, selectedItem: selectedItem);
          },
        );
      case TabPage.meta:
        return ValueListenableBuilder<ItemModel?>(
          valueListenable: listenable,
          builder: (BuildContext context, value, Widget? child) {
            if (value == null) return nil;
            return ItemMetaPage(model: value, selectedItem: selectedItem);
          },
        );
    }
  }
}
