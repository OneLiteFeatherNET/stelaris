import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
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

  /// Returns an indicator if the model contains any kind of chars
  bool get hasChars => selected.chars.hasItems;

  /// Returns a indicator if there is a additional loading process active
  bool get isLoadingMore => selected.isLoadingChars;

  /// Returns the list of chars
  List<FontStringDTO> get chars => selected.chars.items;
}
