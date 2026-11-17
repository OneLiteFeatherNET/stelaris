import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/blockstate/block_state_detail_page.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The selected blockstate and the other contexts of its block, which the
/// export writes into the same file.
class SelectedBlockStateFactory
    extends VmFactory<AppState, BlockStateRules, SelectedBlockStateView> {
  SelectedBlockStateFactory();

  @override
  SelectedBlockStateView fromStore() {
    final selected = state.selectedBlockState!;
    return SelectedBlockStateView(
      selected: selected,
      others: [
        for (final other in state.blockStates.items)
          if (other.key == selected.key && other.id != selected.id) other,
      ],
    );
  }
}

class SelectedBlockStateView extends Vm {
  SelectedBlockStateView({required this.selected, required this.others})
    // The models one by one: a list compares by identity and is built anew
    // on every store change.
    : super(equals: [selected, others.length, ...others]);

  final BlockStateModel selected;
  final List<BlockStateModel> others;
}
