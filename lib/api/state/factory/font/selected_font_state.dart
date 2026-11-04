import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';

class SelectedFontFactory<T extends Widget>
    extends VmFactory<AppState, T, SelectedFontView> {
  SelectedFontFactory();

  @override
  SelectedFontView fromStore() => SelectedFontView(
    selected: state.selectedFont!,
    project: state.selectedProject,
  );
}

class SelectedFontView extends Vm {
  SelectedFontView({required this.selected, required this.project})
    : super(equals: [selected, project]);

  final FontModel selected;

  /// The project the font belongs to, whose textures it can use.
  final Project? project;

  String get name => selected.uiName;
}
