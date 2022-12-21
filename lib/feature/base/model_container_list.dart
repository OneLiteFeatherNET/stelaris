import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/feature/base/model_list.dart';
import 'package:stelaris_ui/util/typedefs.dart';

import '../../api/tabs/tab_pages.dart';

var tabPagesValues = TabPages.values;

var tabs = tabPagesValues
    .map((e) => Tab(
          child: Text(e.content),
        ))
    .toList();

class ModelContainerList<E extends DataModel> extends StatefulWidget {
  final List<E> items;
  final TabPageMapFunction<E> page;
  final MapToDataModelItem<E> mapToDataModelItem;
  final VoidCallback openFunction;
  final ValueNotifier<E?> selectedItem;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final MapToDeleteDialog<E> mapToDeleteDialog;

  const ModelContainerList(
      {Key? key,
      required this.items,
      required this.page,
      required this.mapToDataModelItem,
      required this.openFunction,
      required this.selectedItem,
      required this.mapToDeleteSuccessfully,
      required this.mapToDeleteDialog})
      : super(key: key);

  @override
  State<ModelContainerList<E>> createState() => _ModelContainerListState<E>();
}

class _ModelContainerListState<E extends DataModel>
    extends State<ModelContainerList<E>> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ModelList(
          items: widget.items,
          mapToDataModelItem: widget.mapToDataModelItem,
          selectedItem: widget.selectedItem,
          openFunction: widget.openFunction,
          mapToDeleteDialog: widget.mapToDeleteDialog,
          mapToDeleteSuccessfully: widget.mapToDeleteSuccessfully),
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
                children: tabPagesValues
                    .map((e) => widget.page(e, widget.selectedItem))
                    .toList(),
              ),
            ),
          ))
    ]);
  }
}
