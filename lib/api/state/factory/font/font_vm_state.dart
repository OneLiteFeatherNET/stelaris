import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/model/font_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/font/font_page.dart';

class FontVmFactory extends VmFactory<AppState, FontPage, FontViewModel> {

  FontVmFactory();

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
    if (selected == null) return false;

    final selectedModel = selected!;

    if (selectedModel.id != null && model.id != null) {
      return selectedModel.id == model.id;
    }
    return selectedModel.hashCode == model.hashCode;
  }
}
