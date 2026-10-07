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
    projectKey: state.selectedProject?.key,
  );
}

class SelectedFontView extends Vm {
  SelectedFontView({required this.selected, this.projectKey})
    : super(equals: [selected, projectKey]);

  final FontModel selected;

  /// The key of the open project, the namespace of its resources.
  final String? projectKey;

  String get name => selected.uiName;
}
