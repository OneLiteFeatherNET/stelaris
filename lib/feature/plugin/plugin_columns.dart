import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

enum PluginColumns {

  name("Name"),
  description("Description"),
  version("Version"),
  ref("Ref"),
  actions("Actions");

  final String display;

  const PluginColumns(this.display);

  DataColumn2 toColumn() {
    return DataColumn2(
        label: Text(display, textAlign: TextAlign.center),
        size: ColumnSize.L
    );
  }
}