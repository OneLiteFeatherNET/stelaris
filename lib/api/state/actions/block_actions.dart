import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/util/default.dart';
import '../../api_service.dart';
import '../../model/block_model.dart';
import '../app_state.dart';

class UpdateBlockAction extends ReduxAction<AppState> {
  final BlockModel block;

  UpdateBlockAction(this.block);

  @override
  Future<AppState?> reduce() async {
    var blocks = await ApiService().blockAPI.getAllBlocks();
    return state.copyWith(blocks: blocks);
  }
}

class InitBlockAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    return state.copyWith(blocks: [blocKModel]);
  }

  InitBlockAction();
}

class RemoveBlockAction extends ReduxAction<AppState> {

  final BlockModel model;

  RemoveBlockAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final blocks = List.of(state.blocks, growable: true);
    blocks.remove(model);
    return state.copyWith(blocks: blocks);
  }
}