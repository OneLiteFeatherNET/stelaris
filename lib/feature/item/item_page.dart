import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/item/item_vm_state.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/base/model_text.dart';
import 'package:stelaris/feature/base/paginated_model_view_tab.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_page.dart';
import 'package:stelaris/feature/item/general/item_general_page.dart';
import 'package:stelaris/feature/item/lore/lore_page.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';

class ItemPage extends StatelessWidget {
  const ItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ItemViewModel>(
      vm: () => ItemVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitItemAction()),
      onDispose: (store) =>
          store.dispatch(RemoveSelectItemAction(), notify: false),
      builder: (context, vm) {
        return PaginatedBaseModelViewTabs<ItemModel>(
          mapToDataModelItem: (value) => TextWidget(displayName: value.uiName),
          openFunction: () => _openCreationDialog(context),
          selectedItem: vm.selected,
          mapToDeleteDialog: (value) => createDeleteText(value.uiName, context),
          mapToDeleteSuccessfully: (value) {
            context.dispatch(ItemRemoveAction(value));
            return true;
          },
          callFunction: (model) => context.dispatch(SelectedItemAction(model)),
          page: (page, model) => _mapPageToWidget(page, model),
          models: vm.itemModels,
          tabPages: (pages) => pages,
          compareFunction: (model) => vm.isSelectedItem(model),
          isLoadingMore: vm.isLoadingMore,
          hasMore: vm.hasNextPage,
          tabs: _getTabs(),
          onLoadMore: vm.hasNextPage && !vm.isLoadingMore
              ? () => context.dispatch(InitItemAction())
              : null,
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
            final model = ItemModel(uiName: value);
            context.dispatch(ItemAddAction(model));
            Navigator.pop(context, true);
          },
          formKey: GlobalKey<FormState>(),
          hintText: 'Example name',
          formatters: [
            FilteringTextInputFormatter.allow(stringWithSpacePattern),
          ],
          formFieldValidator: (value) {
            final input = value as String;
            return checkIfEmptyAndReturnErrorString(input, context);
          },
          clearFunction: (text) => text.trim().isNotEmpty,
        );
      },
    );
  }

  List<Tab> _getTabs() {
    return [
      const Tab(child: Text('General')),
      const Tab(child: Text('Meta')),
      const Tab(child: Text('Lore')),
    ];
  }

  /// Maps the given [ItemModel] to the right widget.
  /// If the model is null, it returns an [Expanded] widget with an [EmptyDataWidget].
  /// Otherwise, it returns an instance of [ItemGeneralPage],[EnchantmentPage] or [LorePage].
  Widget _mapPageToWidget(String value, ItemModel? listenable) {
    if (value.trim().isEmpty || listenable == null) {
      return const EmptyDataWidget.standard(
        header: 'No data selected',
        subHeader: 'Please create or selected a model',
      );
    }
    return switch (value) {
      'General' => ItemGeneralPage(key: ValueKey('item_${listenable.id}')),
      'Meta' => const EnchantmentPage(),
      'Lore' => LorePage(key: UniqueKey()),
      _ => const Placeholder(), // optional default case
    };
  }
}
