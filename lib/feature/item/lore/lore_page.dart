import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/state/factory/item/selected_item_state.dart';
import 'package:stelaris_ui/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris_ui/feature/item/lore/empty_lore_list.dart';
import 'package:stelaris_ui/feature/item/lore/lore_action_chips.dart';
import 'package:stelaris_ui/feature/item/lore/lore_confirm_widget.dart';
import 'package:stelaris_ui/feature/item/lore/lore_page_view.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/functions.dart';

class LorePage extends StatefulWidget {
  const LorePage({super.key});

  @override
  State<LorePage> createState() => _LorePageState();
}

class _LorePageState extends State<LorePage> {
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedItemView>(
      vm: () => SelectedItemFactory(),
      onWillChange: (context, store, previousVm, newVm) {
        if ((previousVm.selected.lore?.length ?? 0) >
            (newVm.selected.lore?.length ?? 0)) {
          isEditing = false;
        }
      },
      builder: (context, vm) {
        return Padding(
          padding: const EdgeInsets.only(left: 25, right: 25.0),
          child: Stack(
            children: [
              Column(
                children: [
                  verticalSpacing25,
                  LoreActionChips(
                    dialogFunction: () => _openCreateDialog(vm, context),
                    confirmWidget: LoreConfirmWidget(
                      onConfirm: () => _onConfirm(vm),
                      onSave: () => context.dispatch(ItemDatabaseUpdate()),
                      isEditing: isEditing,
                    ),
                    deleteFunction: _toggleDeleteState,
                    currentIndex: vm.loreLines.length,
                  ),
                  verticalSpacing25,
                  Flexible(
                    child: !vm.hasLoreLines
                        ? const EmptyLoreList()
                        : LorePageView(
                            isEditing: isEditing,
                            view: vm,
                          ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleDeleteState() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _onConfirm(SelectedItemView view) {
    if (view.fieldsToDelete.isEmpty) return;
    final oldEntry = view.selected;
    for (String element in view.fieldsToDelete) {
      view.loreLines.remove(element);
    }
    final newEntry = oldEntry.copyWith(lore: view.loreLines);
    view.clearFieldsToDelete();
    context.dispatch(UpdateItemAction(newEntry));
  }

  void _openCreateDialog(SelectedItemView view, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          valueUpdate: (value) {
            _updateLore(view, value!, true);
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

  void _updateLore(SelectedItemView view, String line, [bool add = true]) {
    if (add) {
      view.loreLines.add(line);
    } else {
      view.loreLines.remove(line);
    }
    final newEntry = view.selected.copyWith(lore: view.loreLines);
    context.dispatch(UpdateItemAction(newEntry));
  }
}
