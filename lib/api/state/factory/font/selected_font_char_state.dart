import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/font/font_string_dto.dart';
import 'package:stelaris/api/model/font_model.dart';
import 'package:stelaris/api/state/app_state.dart';

class SelectedFontCharFactory<T extends Widget>
    extends VmFactory<AppState, T, SelectedFontCharView> {
  SelectedFontCharFactory();

  @override
  SelectedFontCharView fromStore() =>
      SelectedFontCharView(selected: state.selectedFont!);
}

class SelectedFontCharView extends Vm {
  SelectedFontCharView({
    required this.selected,
  }) : super(equals: [selected]);

  final FontModel selected;
  final Set<FontStringDTO> selectedFields = {};

  bool get hasChars => selected.chars.hasItems;

  List<FontStringDTO> get chars => selected.chars.items;

  bool hasChar(FontStringDTO index) => chars.contains(index);

  bool addCharToDeleted(FontStringDTO index) {
    return selectedFields.add(index);
  }

  bool removeCharFromDeleted(FontStringDTO index) {
    return selectedFields.remove(index);
  }

  void clearDeleted() {
    if (selectedFields.isEmpty) return;
    selectedFields.clear();
  }
}
