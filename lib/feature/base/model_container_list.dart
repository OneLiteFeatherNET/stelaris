import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/feature/base/model_list.dart';

import '../../api/tabs/tab_pages.dart';

var tabPagesValues = TabPages.values;

var tabs = tabPagesValues.map((e) => Tab(child: Text(e.content),)).toList();

typedef TabPageMapFunction<E extends DataModel> = Widget Function(TabPages page, ValueNotifier<E?> notification);

class ModelContainerList<E extends DataModel> extends StatefulWidget {

  final List<E> items;
  final TabPageMapFunction page;
  final MapToDataModelItem<E> mapToDataModelItem;
  final VoidCallback openFunction;

  const ModelContainerList({Key? key, required this.items, required this.page, required this.mapToDataModelItem, required this.openFunction}) : super(key: key);

  @override
  State<ModelContainerList> createState() => _ModelContainerListState<E>(items, page, mapToDataModelItem);
}

class _ModelContainerListState<E extends DataModel> extends State<ModelContainerList> {

  final List<E> items;
  final TabPageMapFunction tabPages;
  final MapToDataModelItem<E> mapToDataModelItem;
  final ValueNotifier<E?> selectedItem = ValueNotifier(null);

  _ModelContainerListState(this.items, this.tabPages, this.mapToDataModelItem);

  @override
  Widget build(BuildContext context) {
    return  Row(children: [
      ModelList(items: items, mapToDataModelItem: mapToDataModelItem, selectedItem: selectedItem, openFunction: widget.openFunction),
      DefaultTabController(
          length: tabPagesValues.length,
          child: Expanded(
            child: Scaffold(
              appBar: AppBar(
                toolbarHeight: 0,
                bottom: TabBar(
                  tabs: tabs,
                ),
              ),
              body: TabBarView(
                children: tabPagesValues.map((e) => tabPages(e, selectedItem)).toList(),
              ),
            ),
          ))
    ]);
  }
}
