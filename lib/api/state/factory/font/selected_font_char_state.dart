import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/font/font_string_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/util/font_part.dart';

class SelectedFontCharFactory<T extends Widget>
    extends VmFactory<AppState, T, SelectedFontCharView> {
  SelectedFontCharFactory();

  @override
  SelectedFontCharView fromStore() => SelectedFontCharView(
    selected: state.selectedFont!,
    isLoadingMore: isWaiting(FontCharLoadMoreAction),
  );
}

class SelectedFontCharView extends Vm {
  SelectedFontCharView({required this.selected, required this.isLoadingMore})
    : super(equals: [selected, isLoadingMore]);

  final FontModel selected;

  /// Whether the next page of chars is loading.
  final bool isLoadingMore;

  /// Returns an indicator if the model contains any kind of chars
  bool get hasChars => selected.chars.hasItems;

  /// Returns the list of chars
  List<FontStringDTO> get chars => selected.chars.items;

  List<String> get _lines => [for (final char in chars) char.line];

  /// The distinct lengths of the loaded lines, see [rowLengths]. More than
  /// one means the font is broken.
  late final List<int> lineLengths = rowLengths(_lines);

  /// The length the loaded lines should have, see [expectedRowLength].
  late final int? expectedLineLength = expectedRowLength(_lines);
}
