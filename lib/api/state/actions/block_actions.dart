import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/api_service.dart';
import '../../model/block_model.dart';
import '../app_state.dart';

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
    await ApiService().blockAPI.add(_model);
    var blocks = await ApiService().blockAPI.getAll();
    return state.copyWith(blocks: blocks);
  }
}


class RemoveBlockAction extends ReduxAction<AppState> {

  final BlockModel model;

  RemoveBlockAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().blockAPI.remove(model);
    var blocks = await ApiService().blockAPI.getAll();
    return state.copyWith(blocks: blocks);
  }
}