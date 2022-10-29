import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:stelaris_ui/api/model/block_model.dart';
import 'package:stelaris_ui/api/state/actions/block_actions.dart';

import '../../api/state/app_state.dart';

class BlockList extends StatefulWidget {

  const BlockList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BlockListState();
  }
}

class BlockListState extends State<BlockList> {

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<BlockModel>>(
      onInit: (store) {
        store.dispatch(InitBlockAction());
      },
      converter: (store) {
        return store.state.blocks;
      },
      builder: (context, vm) {
        var blocks = vm.isNotEmpty
            ? vm.map((e) => e.name ?? 'X').toList()
            : List<String>.generate(1, (index) => "1");
        return Container(

        );
      },
    );
  }
}