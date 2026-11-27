import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/blockstate/block_state_page.dart';
import 'package:stelaris_models/stelaris_models.dart';

class BlockStateVmFactory
    extends VmFactory<AppState, BlockStatePage, BlockStateViewModel> {
  BlockStateVmFactory();

  @override
  BlockStateViewModel fromStore() => BlockStateViewModel(
    models: state.blockStates.items,
    hasNextPage: state.blockStates.hasNextPage,
  );
}

class BlockStateViewModel extends Vm {
  final List<BlockStateModel> models;
  final bool hasNextPage;

  BlockStateViewModel({
    required this.models,
    required this.hasNextPage,
  }) : super(equals: [models, hasNextPage]);
}
