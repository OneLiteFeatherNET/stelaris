import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/item/item_lore_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/item/item_lore_view_state.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/feature/item/lore/lore_action_chips.dart';
import 'package:stelaris/feature/item/lore/lore_page_view.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';

class LorePage extends StatelessWidget {
  const LorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ItemLoreView>(
      vm: () => ItemLoreViewFactory(),
      onInit: (store) => store.dispatchAndWait(ItemLoreFetchAction()),
      builder: (context, vm) {
        return Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Stack(
            children: [
              Column(
                children: [
                  verticalSpacing25,
                  LoreActionChips(
                    dialogFunction: () => _openCreateDialog(vm, context),
                    currentIndex: vm.selected.lore.items.length,
                  ),
                  verticalSpacing25,
                  Flexible(
                    child: !vm.selected.lore.hasItems
                        ? const EmptyDataWidget()
                        : LorePageView(view: vm),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCreateDialog(ItemLoreView view, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          valueUpdate: (value) {
            final ItemLoreDto dto = ItemLoreDto(text: value);
            context.dispatch(ItemLoreAddAction(dto));
            Navigator.pop(context);
          },
          formFieldValidator: (value) {
            final String input = value as String;
            return checkIfEmptyAndReturnErrorString(input, context);
          },
          title: context.l10n.button_add_new_line,
          formKey: GlobalKey<FormState>(),
        );
      },
    );
  }
}
