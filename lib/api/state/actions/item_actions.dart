import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/api_service.dart';

import '../../model/item_model.dart';
import '../app_state.dart';

class UpdateItemAction extends ReduxAction<AppState> {
  final ItemModel oldEntry;
  final ItemModel newEntry;

  UpdateItemAction(this.oldEntry, this.newEntry);

  @override
  Future<AppState?> reduce() async {
    final items = List.of(state.items, growable: true);
    items.remove(oldEntry);
    items.add(newEntry);
    return state.copyWith(items: items);
  }
}

class InitItemAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    var items = await ApiService().itemApi.getAllItems();
    return state.copyWith(items: items);
  }

  InitItemAction();
}

class AddItemAction extends ReduxAction<AppState> {

  final ItemModel _model;

  AddItemAction(this._model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().itemApi.addItem(_model);
    var items = await ApiService().itemApi.getAllItems();
    return state.copyWith(items: items);
  }
}


class RemoveItemAction extends ReduxAction<AppState> {

  final ItemModel model;

  RemoveItemAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().itemApi.remove(model);
    var items = await ApiService().itemApi.getAllItems();
    return state.copyWith(items: items);
  }
}