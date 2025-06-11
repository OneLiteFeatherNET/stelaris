import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/util/constants.dart';

class SelectedItemFactory<T extends Widget>
    extends VmFactory<AppState, T, SelectedItemView> {
  SelectedItemFactory();

  @override
  SelectedItemView fromStore() =>
      SelectedItemView(selected: state.selectedItem!);
}

class SelectedItemView extends Vm {
  SelectedItemView({required this.selected}) 
      // Include both the ID and the selected object itself
      // The ID helps detect model switches, while the object reference helps detect property updates
      : super(equals: [selected, selected.id]) {
    loreLines = List.of(selected.lore ?? [], growable: true);
  }

  final ItemModel selected;
  late final List<String> loreLines;
  final Set<String> fieldsToDelete = {};

  String get material => selected.material ?? defaultMaterial;

  bool get hasLoreLines => loreLines.isNotEmpty;

  int get loreCount => loreLines.length;

  void addLoreLine(String line) {
    loreLines.add(line);
  }

  void removeLoreLine(int index) {
    loreLines.removeAt(index);
  }

  bool addFieldToDelete(String field) {
    return fieldsToDelete.add(field);
  }

  bool removeFieldToDelete(String field) {
    return fieldsToDelete.remove(field);
  }

  void clearFieldsToDelete() {
    fieldsToDelete.clear();
  }
}
