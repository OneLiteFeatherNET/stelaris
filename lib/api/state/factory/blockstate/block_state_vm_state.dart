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
    isLoadingMore: state.isLoadingMoreBlockStates,
  );
}

class BlockStateViewModel extends Vm {
  final List<BlockStateModel> models;
  final bool hasNextPage;
  final bool isLoadingMore;

  BlockStateViewModel({
    required this.models,
    required this.hasNextPage,
    required this.isLoadingMore,
  }) : super(equals: [models, hasNextPage, isLoadingMore]);
}
