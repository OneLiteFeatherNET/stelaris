import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/state/actions/font_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/font/font_page.dart';

class FontVmFactory extends VmFactory<AppState, FontPage, FontViewModel> {

  FontVmFactory();

  Future<void> updateSelectedEntry(FontModel model) async {
    dispatchAsync(SelectFontAction(model));
    // dispatch(SelectedItemAction(itemModel));
  }

  Future<void> removeSelectedEntry(FontModel model) async {
    dispatchAsync(RemoveSelectedFont(model));
    // dispatch(RemoveSele(itemModel));
  }

  @override
  FontViewModel? fromStore() => FontViewModel(models: state.fonts, selected: state.selectedFont);
}

class FontViewModel extends Vm {
  final List<FontModel> models;
  final FontModel? selected;

  FontViewModel({
    required this.models,
    required this.selected,
  }) : super(equals: [models, selected]);

  bool isSelectedItem(FontModel model) {
    return selected != null && selected.hashCode == model.hashCode;
  }
}
