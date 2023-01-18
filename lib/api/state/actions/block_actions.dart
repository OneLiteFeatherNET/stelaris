import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/util/default.dart';
import '../../model/block_model.dart';
import '../app_state.dart';

class UpdateBlockAction extends ReduxAction<AppState> {
  final BlockModel oldEntry;
  final BlockModel newEntry;

  UpdateBlockAction(this.oldEntry, this.newEntry);

  @override
  Future<AppState?> reduce() async {
    final items = List.of(state.blocks, growable: true);
    items.remove(oldEntry);
    items.add(newEntry);
    return state.copyWith(blocks: items);
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