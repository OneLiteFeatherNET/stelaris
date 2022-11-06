import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/state/actions/block_actions.dart';

import '../../api/state/app_state.dart';

class FontList extends StatefulWidget {

  const FontList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FontListState();
  }
}

class FontListState extends State<FontList> {

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<FontModel>>(
      onInit: (store) {
        store.dispatch(InitBlockAction());
      },
      converter: (store) {
        return store.state.fonts;
      },
      builder: (context, vm) {
        var fonts = vm.isNotEmpty
            ? vm.map((e) => e.name ?? 'X').toList()
            : List<String>.generate(1, (index) => "1");
        return Container(

        );
      },
    );
  }
}