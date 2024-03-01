import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nil/nil.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/state/factory/item_vm_state.dart';
import 'package:stelaris_ui/feature/base/base_model_view_tabs.dart';
import 'package:stelaris_ui/feature/base/model_text.dart';
import 'package:stelaris_ui/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris_ui/feature/item/general/item_general_page.dart';
import 'package:stelaris_ui/feature/item/meta/item_meta_page.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/functions.dart';

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
          openFunction: () => _openCreationDialog(context),
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
          tabs: _getTabs(),
        );
      },
    );
  }

  void _openCreationDialog(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          title: 'Create new item',
          valueUpdate: (value) {
            final model = ItemModel(modelName: value);
            StoreProvider.dispatch(context, AddItemAction(model));
            Navigator.pop(context, true);
          },
          formKey: GlobalKey<FormState>(),
          hintText: 'Example name',
          formatters: [
            FilteringTextInputFormatter.allow(stringWithSpacePattern),
          ],
          formFieldValidator: (value) {
            var input = value as String;
            return checkIfEmptyAndReturnErrorString(input, context);
          },
          clearFunction: (text) => text.trim().isNotEmpty,
        );
      },
    );
  }

  List<Tab> _getTabs() {
    return [
      const Tab(
        child: Text(
          'General',
        ),
      ),
      const Tab(
        child: Text(
          'Meta',
        ),
      ),
    ];
  }

  Widget _mapPageToWidget(String value, ItemModel? listenable) {
    if (value.trim().isEmpty) return nil;
    switch (value) {
      case 'General':
        if (listenable == null) return nil;
        return ItemGeneralPage(model: listenable);
      case 'Meta':
        if (listenable == null) return nil;
        return ItemMetaPage(model: listenable);
    }
    return nil;
  }
}
