import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/model/block_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/block/block_page.dart';

class BlockVmFactory extends VmFactory<AppState, BlockPage, BlockViewModel> {

  BlockVmFactory();

  Future<void> updateSelectedEntry(BlockModel model) async {
   // dispatchAsync(SelectedItemAction(itemModel));
  }

  Future<void> removeSelectedEntry(BlockModel model) async {
   // dispatchAsync(RemoveSele(itemModel));
  }

  @override
  BlockViewModel? fromStore() =>
      BlockViewModel(models: state.blocks, selected: state.selectedBlock);
}

class BlockViewModel extends Vm {
  final List<BlockModel> models;
  final BlockModel? selected;

  BlockViewModel({
    required this.models,
    required this.selected,
  }) : super(equals: [models, selected]);

  bool isSelectedItem(BlockModel model) {
    if (selected == null) return false;

    final selectedModel = selected!;

    if (selectedModel.id != null && model.id != null) {
      return selectedModel.id == model.id;
    }
    return selectedModel.hashCode == model.hashCode;
  }
}
