import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/state/factory/item_vm_state.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/feature/base/base_model_view_tabs.dart';
import 'package:stelaris_ui/feature/base/model_text.dart';
import 'package:stelaris_ui/feature/dialogs/setup_dialog.dart';
import 'package:stelaris_ui/feature/item/general/item_general_page.dart';
import 'package:stelaris_ui/feature/item/item_group.dart';
import 'package:stelaris_ui/feature/item/meta/item_meta_page.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class ItemPage extends StatelessWidget {
  const ItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ItemViewModel>(
      vm: () => ItemVmFactory(),
      onInit: (store) => store.dispatchAsync(InitItemAction()),
      builder: (context, vm) {
        return BaseModelViewTabs<ItemModel>(
          mapToDataModelItem: (value) =>
              ModelText(displayName: value.modelName),
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
                      group: ItemGroup.misc.display,
                    );
                  },
                  finishCallback: (model) {
                    StoreProvider.dispatch(context, AddItemAction(model));
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
          selectedItem: vm.selected,
          mapToDeleteDialog: (value) {
            return [
              TextSpan(
                  text: context.l10n.delete_dialog_first_line,
                  style: whiteStyle),
              TextSpan(
                text: value.modelName ?? unknownEntry,
                style: redStyle,
              ),
              TextSpan(
                text: context.l10n.delete_dialog_entry,
                style: whiteStyle,
              ),
            ];
          },
          mapToDeleteSuccessfully: (value) {
            StoreProvider.dispatch(context, RemoveItemAction(value));
            return true;
          },
          callFunction: (model) =>
              StoreProvider.dispatch(context, SelectedItemAction(model)),
          page: (page, model) => _mapPageToWidget(page, model),
          models: vm.itemModels,
          tabPages: (pages) => pages,
          compareFunction: (model) => vm.isSelectedItem(model),
        );
      },
    );
  }

  Widget _mapPageToWidget(TabPage value, ItemModel? listenable) {
    switch (value) {
      case TabPage.general:
        if (listenable == null) return nil;
        return ItemGeneralPage(model: listenable);
      case TabPage.meta:
        if (listenable == null) return nil;
        return ItemMetaPage(model: listenable);
    }
  }
}
