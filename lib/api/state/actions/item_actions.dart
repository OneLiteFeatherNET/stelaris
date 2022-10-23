import 'package:async_redux/async_redux.dart';

import '../../api_service.dart';
import '../../model/item_model.dart';
import '../app_state.dart';

class UpdateItemAction extends ReduxAction<AppState> {
  final ItemModel item;

  UpdateItemAction(this.item);

  @override
  Future<AppState?> reduce() async {
    var items = await ApiService().itemApi.getAllItems();
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