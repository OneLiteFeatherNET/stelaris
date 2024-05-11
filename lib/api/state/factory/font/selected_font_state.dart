import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/util/constants.dart';

class SelectedFontFactory<T extends Widget>
    extends VmFactory<AppState, T, SelectedFontView> {
  SelectedFontFactory();

  @override
  SelectedFontView fromStore() =>
      SelectedFontView(selected: state.selectedFont!);
}

class SelectedFontView extends Vm {
  SelectedFontView({required this.selected}) : super(equals: [selected]);

  final FontModel selected;

  String get name => selected.name ?? unknownEntry;
}
