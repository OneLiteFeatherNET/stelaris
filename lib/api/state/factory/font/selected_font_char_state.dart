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
  SelectedFontCharView({required this.selected}) : super(equals: [selected]);

  final FontModel selected;
  final Set<FontStringDTO> selectedFields = {};

  /// Returns a indicator if there model contains any kind of chars
  bool get hasChars => selected.chars.hasItems;

  /// Returns a indicator if there is a additional loading process active
  bool get isLoadingMore => selected.isLoadingChars;

  /// Returns the list of chars
  List<FontStringDTO> get chars => selected.chars.items;

  /// Returns true if the [index] is flagged for deletion
  bool hasChar(FontStringDTO index) => chars.contains(index);

  /// Adds a entry which was flagged for deletion to the internal list
  /// [index] the entry to add
  /// Returns true if the entry was added
  bool addCharToDeleted(FontStringDTO index) {
    return selectedFields.add(index);
  }

  /// Removes a entry which was flagged for deletion from the internal list
  /// [index] the entry to remove
  /// Returns true if the entry was found and removed
  bool removeCharFromDeleted(FontStringDTO index) {
    return selectedFields.remove(index);
  }

  /// Clears each selected fields for the deletion
  void clearDeleted() {
    if (selectedFields.isEmpty) return;
    selectedFields.clear();
  }
}
