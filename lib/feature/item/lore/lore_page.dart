import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';
import 'package:stelaris_ui/feature/base/button/entry_buttons.dart';
import 'package:stelaris_ui/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris_ui/feature/item/lore/empty_lore_list.dart';
import 'package:stelaris_ui/feature/item/lore/grabbed_card.dart';
import 'package:stelaris_ui/feature/item/lore/lore_action_chips.dart';
import 'package:stelaris_ui/feature/item/lore/lore_confirm_widget.dart';
import 'package:stelaris_ui/feature/item/lore/lore_delete_checkbox.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/functions.dart';

class LorePage extends StatefulWidget {
  final ItemModel model;

  const LorePage({
    required this.model,
    super.key,
  });

  @override
  State<LorePage> createState() => _LorePageState();
}

class _LorePageState extends State<LorePage> {
  late List<String> loreLines;
  final List<int> selectedToDelete = [];
  bool isEditing = false;

  @override
  void initState() {
    loreLines = List.of(widget.model.lore ?? []);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25.0),
      child: Stack(
        children: [
          Column(
            children: [
              verticalSpacing25,
              LoreActionChips(
                dialogFunction: () => _openCreateDialog(context),
                confirmWidget: LoreConfirmWidget(
                  onConfirm: _onConfirm,
                  onSave: _saveModel,
                  isEditing: isEditing,
                ),
                deleteFunction: _toggleDeleteState,
                currentIndex: loreLines.length,
              ),
              verticalSpacing25,
              Flexible(
                child: loreLines.isEmpty
                    ? const EmptyLoreList()
                    : ReorderableListView.builder(
                  proxyDecorator: (child, index, animation) =>
                      GrabbedCard(
                        child: child,
                      ),
                  itemBuilder: (context, index) {
                    final key = loreLines[index];
                    return ListTile(
                      key: Key(index.toString()),
                      title: Text(
                        key,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: Text("${index + 1}"),
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: isEditing
                            ? LoreDeleteCheckbox(
                          index: index,
                          function: _loreManipulate,
                        )
                            : EntryButtons(
                          editTitle:
                          context.l10n.dialog_lore_edit_title,
                          model: widget.model,
                          name: key,
                          value: key,
                          formFieldValidator: (value) {
                            var input = value as String;
                            return checkIfEmptyAndReturnErrorString(
                              input,
                              context,
                            );
                          },
                          delete: (ItemModel? value) {
                            final oldEntry = widget.model;
                            List<String> oldLores =
                            List.of(oldEntry.lore ?? []);
                            oldLores.remove(key);
                            final newEntry =
                            oldEntry.copyWith(lore: oldLores);
                            _updateData(
                              widget.model,
                              newEntry,
                              oldLores,
                            );
                          },
                          update: _updateLoreLine,
                        ),
                      ),
                    );
                  },
                  itemCount: loreLines.length,
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex == newIndex) return;
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }

                    if (newIndex > loreLines.length - 1) {
                      newIndex = loreLines.length - 1;
                    }
                    List<String> oldLores =
                    List.of(loreLines, growable: true);
                    final item = oldLores.removeAt(oldIndex);
                    oldLores.insert(newIndex, item);
                    setState(() {
                      loreLines = oldLores;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateLoreLine(String? value, String? key) {
    final oldEntry = widget.model;
    List<String> oldLores = List.of(oldEntry.lore ?? []);
    int index = oldLores.indexWhere(
          (element) =>
          identical(
            element,
            value,
          ),
    );
    oldLores[index] = key!;
    final newEntry = oldEntry.copyWith(lore: oldLores);
    setState(() {
      loreLines = oldLores;
      StoreProvider.dispatch(
        context,
        UpdateItemAction(
          oldEntry,
          newEntry,
        ),
      );
    });
  }

  void _toggleDeleteState() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) selectedToDelete.clear();
    });
  }

  void _onConfirm() {
    if (selectedToDelete.isEmpty) return;
    final oldEntry = widget.model;
    List<String> lines = List.of(oldEntry.lore ?? [], growable: true);
    for (var element in selectedToDelete) {
      lines.removeAt(selectedToDelete[element]);
    }
    final newEntry = oldEntry.copyWith(lore: lines);
    _updateData(oldEntry, newEntry, lines);
    _toggleDeleteState();
  }

  void _loreManipulate(bool add, int index) {
    if (add) {
      selectedToDelete.add(index);
    } else {
      selectedToDelete.remove(index);
    }
  }

  void _updateData(ItemModel oldEntry,
      ItemModel newEntry,
      List<String> newLines,) {
    setState(() {
      loreLines = newLines;
      StoreProvider.dispatch(
        context,
        UpdateItemAction(
          oldEntry,
          newEntry,
        ),
      );
    });
  }

  void _saveModel() async {
    final ItemModel newModel = widget.model.copyWith(lore: loreLines);
    await StoreProvider.dispatch(
      context,
      UpdateItemAction(
        widget.model,
        newModel,
      ),
    );
    ApiService().itemApi.update(widget.model);
  }

  void _openCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          valueUpdate: (value) {
            _updateLore(value!, true);
            Navigator.pop(context);
          },
          formFieldValidator: (value) {
            var input = value as String;
            return checkIfEmptyAndReturnErrorString(input, context);
          },
          title: context.l10n.button_add_new_line,
          formKey: GlobalKey<FormState>(),
        );
      },
    );
  }

  void _updateLore(String line, [bool add = true]) {
    final oldEntry = widget.model;
    List<String> oldLores = List.of(oldEntry.lore ?? []);
    if (add) {
      oldLores.add(line);
    } else {
      oldLores.remove(line);
    }
    final newEntry = oldEntry.copyWith(lore: oldLores);
    _updateData(oldEntry, newEntry, oldLores);
  }
}
