import 'package:async_redux/async_redux.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/plugin_model.dart';
import 'package:stelaris_ui/api/state/actions/plugin_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/plugin/plugin_columns.dart';
import 'package:stelaris_ui/feature/plugin/plugin_data.dart';

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
        return Scaffold(
          body: Stack(
            children: [
              Row(
                children: [
                  getSearchBar(),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: getAddButton(context),
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 100, left: 100, right: 100),
                child: getTable()
              )
              ],
          ),
        );
      },
    );
  }

  Widget getAddButton(BuildContext context) {
    return FloatingActionButton.extended(
      label: const Text("Add"),
      backgroundColor: Colors.black54,
      icon: const Icon(Icons.add, size: 24.0),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                  child: SizedBox(
                      width: 400, height: 400, child: openPluginDialog()));
            });
      },
    );
  }

  Widget openPluginDialog() {
    //TODO: Implement
    return const Text("Implement feature");
  }

  //TODO: Check PaginatedDataSource
  Widget getTable() {
    var dataMap = Map<String, dynamic>();
    dataMap.putIfAbsent("name", () => "Aves");
    dataMap.putIfAbsent("version", () => "1.2,0-SNAPSHOT");
    dataMap.putIfAbsent("ref", () => "ref-12313as");
    List<PluginModel> model = [];
    model.add(PluginModel.fromJson(dataMap));

    PluginData _data = PluginData(plugins: model);

    var values = PluginColumns.values;

    List<DataColumn2> dataColumns = [];

    for (var value in values) {
      dataColumns.add(value.toColumn());
    }

    return PaginatedDataTable2(
      columns: dataColumns,
      source: _data,
      fit: FlexFit.tight,
      wrapInCard: false,
      minWidth: 400,
      empty: Container(
          padding: const EdgeInsets.only(top: 150),
          child: const Text("No Data"),
      ),
    );
  }

  Widget getSearchBar() {
    return Container(
      height: 50,
      width: 600,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey
        ),
        borderRadius: BorderRadius.circular(12)
      ),
      child: const TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Search for a plugin...",
          prefixIcon: Icon(Icons.search)
        ),
      ),
    );
  }
}
