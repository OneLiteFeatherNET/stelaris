import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/actions/item_actions.dart';

import '../../api/state/app_state.dart';

class ItemList extends StatefulWidget {

  const ItemList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ItemListState();
  }
}

class ItemListState extends State<ItemList> {

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<ItemModel>>(
      onInit: (store) {
        store.dispatch(InitItemAction());
      },
      converter: (store) {
        return store.state.items;
      },
      builder: (context, vm) {
        var items = vm.isNotEmpty
            ? vm.map((e) => e.name ?? 'X').toList()
            : List<String>.generate(1, (index) => "1");
        return Container(

        );
      },
    );
  }
}