import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
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
    : super(equals: [selected, selected.id]);

  final ItemModel selected;
  final Set<String> fieldsToDelete = {};

  String get material => selected.material ?? defaultMaterial;
}
