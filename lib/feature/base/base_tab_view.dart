import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

abstract class BaseTabView<T extends DataModel> {

  //TODO: Update this class
  @protected
  Widget tabBarView(List<Widget> views);

  @protected
  List<Tab> getTabEntries();
}