import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

abstract class BaseTabView<T extends DataModel> {

  @protected
  Widget tabBarView(List<Widget> views);

  @protected
  TabBar getTabBar();
}