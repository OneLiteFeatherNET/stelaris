import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/block_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';

class SelectBlockAction extends ReduxAction<AppState> {

  final BlockModel model;

  SelectBlockAction(this.model);

  @override
  AppState reduce() {
    return state.copyWith(selectedBlock: model);
  }
}

class RemoveBlockFont extends ReduxAction<AppState> {

  final BlockModel model;

  RemoveBlockFont(this.model);

  @override
  AppState? reduce() {
    if (state.selectedBlock == null) return null;
    return state.copyWith(selectedBlock: null);
  }
}

class UpdateBlockAction extends ReduxAction<AppState> {
  final BlockModel oldEntry;
  final BlockModel newEntry;

  UpdateBlockAction(this.oldEntry, this.newEntry);

  @override
  Future<AppState?> reduce() async {
    final items = List.of(state.blocks, growable: true);
    items.removeAt(items.indexWhere((element) => element.id == oldEntry.id));
    items.add(newEntry);
    return state.copyWith(blocks: items);
  }
}

class InitBlockAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    var blocks = await ApiService().blockAPI.getAll();
    return state.copyWith(blocks: blocks);
  }

  InitBlockAction();
}

class AddBlockAction extends ReduxAction<AppState> {

  final BlockModel _model;

  AddBlockAction(this._model);

  @override
  Future<AppState?> reduce() async {
    var addedBlock = await ApiService().blockAPI.add(_model);
    final List<BlockModel> blocks = List.of(state.blocks, growable: true);
    blocks.add(addedBlock);
    return state.copyWith(blocks: blocks, selectedBlock: addedBlock);
  }
}


class RemoveBlockAction extends ReduxAction<AppState> {

  final BlockModel model;

  RemoveBlockAction(this.model);

  @override
  Future<AppState?> reduce() async {
    var removed = await ApiService().blockAPI.remove(model);
    var blocks = List.of(state.blocks, growable: true);
    blocks.remove(removed);
    return state.copyWith(blocks: blocks);
  }
}