import 'package:flutter/material.dart';

import '../../api/model/plugin_model.dart';

class PluginData extends DataTableSource {

  List<PluginModel> plugins;

  PluginData({required this.plugins});

  @override
  DataRow? getRow(int index) {
    // TODO: implement getRow
    throw UnimplementedError();
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => throw UnimplementedError();

  @override
  // TODO: implement rowCount
  int get rowCount => throw UnimplementedError();

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => throw UnimplementedError();

}