import 'package:async_redux/async_redux.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/plugin_model.dart';
import 'package:stelaris_ui/api/state/actions/plugin_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/dialogs/stepper/setup_stepper.dart';
import 'package:stelaris_ui/feature/plugin/plugin_columns.dart';
import 'package:stelaris_ui/feature/plugin/plugin_data.dart';

import '../base/button/add_button.dart';

const Radius radius = Radius.circular(10);
const BorderRadius borderRadius = BorderRadius.only(
    topLeft: radius,
    topRight: radius,
    bottomLeft: radius,
    bottomRight: radius
);

const SizedBox spaceBox = SizedBox(height: 10);
const EdgeInsets top = EdgeInsets.only(top: 10);
const EdgeInsets all = EdgeInsets.all(20);
BoxDecoration boxDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: borderRadius,
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.5),
      blurRadius: 4,
      offset: const Offset(4, 8), // changes position of shadow
    ),
  ],
);

const BorderSide side = BorderSide(
color: Colors.black);

class PluginPage extends StatefulWidget {
  const PluginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PluginPageState();
  }
}

class PluginPageState extends State<PluginPage> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<PluginModel>>(
      onInit: (store) {
        if (store.state.plugins.isEmpty) {
          store.dispatch(InitPluginAction());
        }
      },
      converter: (store) {
        return store.state.plugins;
      },
      builder: (context, vm) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 100, left: 100, right: 100),
                child: SizedBox(
                  height: 700,
                  child: Container(
                    decoration: boxDecoration,
                    child: getTable(vm),
                  ),
                )
              )
              ],
          ),
        );
      },
    );
  }

  //TODO: Check PaginatedDataSource
  Widget getTable(List<PluginModel> plugins) {
    PluginData data = PluginData(plugins: plugins);

    var values = PluginColumns.values;

    List<DataColumn2> dataColumns = [];

    for (var value in values) {
      dataColumns.add(value.toColumn());
    }

    return PaginatedDataTable2(
      border: const TableBorder(
        top: side,
        bottom: side,
        left: side,
        right: side,
        horizontalInside: side,
        verticalInside: side
      ),
      headingRowColor: MaterialStateProperty.all(Colors.blueAccent),
      header: Row(
        children: [
          AddButton(
              openFunction: () {
                showDialog(context: context,
                    useRootNavigator: false,
                    builder: (BuildContext context) {
                  return SetupStepper<PluginModel>(
                    buildModel: (name, description) {
                      return PluginModel(name: name, description: description);
                    },
                    finishCallback: (model) {
                      StoreProvider.dispatch(context, InitPluginAction());
                      Navigator.pop(context);
                    return;
                  },);
                });
              },
          ),
        ],
      ),
      columns: dataColumns,
      source: data,
      fit: FlexFit.tight,
      wrapInCard: false,
      minWidth: 400,
      empty: Container(
          padding: const EdgeInsets.only(top: 150),
          child: const Text("No Data"),
      ),
    );
  }
}
