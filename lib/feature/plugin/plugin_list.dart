import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/plugin_model.dart';
import 'package:stelaris_ui/api/state/actions/plugin_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';

class PluginList extends StatefulWidget {

  const PluginList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PluginListState();
  }
}

class PluginListState extends State<PluginList> {

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<PluginModel>>(
      onInit: (store) {
        store.dispatch(InitPluginAction());
      },
      converter: (store) {
        return store.state.plugins;
      },
      builder: (context, vm) {
        var plugins = vm.isNotEmpty
            ? vm.map((e) => e.name ?? 'X').toList()
            : List<String>.generate(1, (index) => "1");
        return Container(

        );
      },
    );
  }
}