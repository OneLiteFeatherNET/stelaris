import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/font_model.dart';
import 'package:stelaris/api/state/app_state.dart';

class SelectedFontFactory<T extends Widget>
    extends VmFactory<AppState, T, SelectedFontView> {
  SelectedFontFactory();

  @override
  SelectedFontView? fromStore() =>
      SelectedFontView(selected: state.selectedFont!);
}

class SelectedFontView extends Vm {
  SelectedFontView({
    required this.selected,
  }) : super(equals: [selected]);

  final FontModel selected;
  final Set<String> selectedFields = {};

  bool get hasChars => selected.chars == null || selected.chars!.isNotEmpty;

  List<String> get chars => selected.chars ?? [];

  bool hasChar(String index) => chars.contains(index);

  bool addCharToDeleted(String index) {
    return selectedFields.add(index);
  }

  bool removeCharFromDeleted(String index) {
    return selectedFields.remove(index);
  }

  void clearDeleted() {
    if (selectedFields.isEmpty) return;
    selectedFields.clear();
  }
}
