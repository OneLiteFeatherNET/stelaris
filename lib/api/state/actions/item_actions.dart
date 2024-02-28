import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';

class SelectedItemAction extends ReduxAction<AppState> {

  final ItemModel model;

  SelectedItemAction(this.model);

  @override
  AppState reduce() {
    return state.copyWith(selectedItem: model);
  }
}

class RemoveSelectItemAction extends ReduxAction<AppState> {

  final ItemModel model;

  RemoveSelectItemAction(this.model);

  @override
  AppState? reduce() {
    if (state.selectedItem == null) return null;
    return state.copyWith(selectedItem: null);
  }
}

class UpdateItemAction extends ReduxAction<AppState> {
  final ItemModel oldEntry;
  final ItemModel newEntry;

  UpdateItemAction(this.oldEntry, this.newEntry);

  @override
  Future<AppState?> reduce() async {
    final items = List.of(state.items, growable: true);
    int index = items.indexWhere((element) => element.id == oldEntry.id);
    items.removeAt(index);
    items.insert(index, newEntry);
    return state.copyWith(items: items, selectedItem: newEntry);
  }
}

class InitItemAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    var items = await ApiService().itemApi.getAll();
    if (items.isEmpty) return null;
    return state.copyWith(items: items);
  }

  InitItemAction();
}

class AddItemAction extends ReduxAction<AppState> {

  final ItemModel _model;

  AddItemAction(this._model);

  @override
  Future<AppState?> reduce() async {
    var added = await ApiService().itemApi.add(_model);
    final List<ItemModel> items = List.of(state.items, growable: true);
    items.add(added);
    return state.copyWith(items: items, selectedItem: added);
  }
}

class RemoveItemAction extends ReduxAction<AppState> {

  final ItemModel model;

  RemoveItemAction(this.model);

  @override
  Future<AppState?> reduce() async {
    var removedEntry = await ApiService().itemApi.remove(model);
    List<ItemModel> items = List.of(state.items, growable: true);
    items.removeWhere((element) => element.id == removedEntry.id);
    return state.copyWith(items: items, selectedItem: null);
  }
}
