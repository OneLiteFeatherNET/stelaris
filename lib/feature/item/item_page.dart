import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';
import 'package:stelaris_ui/feature/base/model_text.dart';
import 'package:stelaris_ui/feature/dialogs/setup_dialog.dart';
import 'package:stelaris_ui/feature/item/item_general_page.dart';
import 'package:stelaris_ui/feature/item/item_group.dart';
import 'package:stelaris_ui/feature/item/item_meta_page.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

final ValueNotifier<ItemModel?> selectedItem = ValueNotifier(null);

class ItemPage extends StatelessWidget with BaseLayout {
  const ItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ModelContainerList<ItemModel>(
      converter: (store) => store.state.items,
      action: InitItemAction(),
      tabPages: (pages) => pages,
      mapToDeleteDialog: (value) {
        return [
          TextSpan(
              text: context.l10n.delete_dialog_first_line, style: whiteStyle),
          TextSpan(text: value.modelName ?? unknownEntry, style: redStyle),
          TextSpan(text: context.l10n.delete_dialog_entry, style: whiteStyle),
        ];
      },
      mapToDeleteSuccessfully: (value) {
        StoreProvider.dispatch(context, RemoveItemAction(value));
        return true;
      },
      page: mapPageToWidget,
      mapToDataModelItem: (value) => ModelText(displayName: value.modelName),
      selectedItem: selectedItem,
      openFunction: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (BuildContext context) {
            return SetUpDialog<ItemModel>(
              buildModel: (name, description) {
                return ItemModel(
                    modelName: name,
                    description: description,
                    group: ItemGroup.misc.display);
              },
              finishCallback: (model) {
                StoreProvider.dispatch(context, AddItemAction(model));
                Navigator.pop(context);
                selectedItem.value = model;
              },
            );
          },
        );
      },
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
