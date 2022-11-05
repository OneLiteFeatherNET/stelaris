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
        return Scaffold(
          body: Stack(
              children: [
                Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: getTable()
                ),
                getAddButton(context)
              ]
          ),
        );
      },
    );
  }

  Widget getAddButton(BuildContext context) {
    return Align(
      alignment: const Alignment(0.99, 0.97),
      child: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                    child: SizedBox(
                        width: 400, height: 400, child: openPluginDialog()));
              });
        },
      ),
    );
  }

  Widget openPluginDialog() {
    return Stepper(currentStep: 0, type: StepperType.horizontal, steps: [
      Step(
          title: const Text("Hallo"),
          content: Container(child: const Text("Hallo")))
    ]);
  }

  //TODO: Check PaginatedDataSource
  Widget getTable() {
    return DataTable(
      columns: [
        DataColumn(
          label: Container(
            padding: const EdgeInsets.all(12),
            child: Text("Name"),
          ),
        ),
        DataColumn(
            label: Container(
              padding: const EdgeInsets.all(12),
              child: Text("Version"),
            )),
        DataColumn(
            label: Container(
              padding: const EdgeInsets.all(12),
              child: Text("ref"),
            )),
      ],
      rows: [
        DataRow(cells: [
          DataCell(Text("Aves")),
          DataCell(Text("1.2.0-SNAPSHOT")),
          DataCell(Text("abd23d"))
        ])
      ],
    );
  }
}
