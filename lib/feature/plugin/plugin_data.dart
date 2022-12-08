import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/plugin/plugins_actions.dart';

import '../../api/model/plugin_model.dart';

class PluginData extends DataTableSource {

  List<PluginModel> plugins;

  PluginData({required this.plugins});

  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(plugins[index].name.toString())),
      DataCell(Text(plugins[index].description.toString())),
      DataCell(Text(plugins[index].versionsString.toString())),
      DataCell(Text(plugins[index].ref.toString())),
      DataCell(Row(
        children: [
          PluginAction.edit.toButton((action) {
          }),
          PluginAction.remove.toButton((action) {

          })
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => plugins.length;

  @override
  int get selectedRowCount => 0;
}
