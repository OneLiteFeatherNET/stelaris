import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/feature/base/model_list.dart';
import 'package:stelaris_ui/util/typedefs.dart';

const List<TabPage> tabPagesValues = TabPage.values;

List<Tab> tabs = tabPagesValues
    .map((e) => Tab(
          child: Text(e.content),
        ))
    .toList();

class ModelContainerList<E extends DataModel> extends StatefulWidget {
  final TabPageMapFunction<E> page;
  final MapToDataModelItem<E> mapToDataModelItem;
  final VoidCallback openFunction;
  final ValueNotifier<E?> selectedItem;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToTabPages tabPages;
  final ReduxAction<AppState> action;
  final List<DataModel> Function(Store<AppState>) converter;

  const ModelContainerList({
    required this.action,
    required this.page,
    required this.mapToDataModelItem,
    required this.openFunction,
    required this.selectedItem,
    required this.mapToDeleteSuccessfully,
    required this.mapToDeleteDialog,
    required this.tabPages,
    required this.converter,
    super.key,
  });

  @override
  State<ModelContainerList<E>> createState() => _ModelContainerListState<E>();
}

class _ModelContainerListState<E extends DataModel>
    extends State<ModelContainerList<E>> {
  @override
  Widget build(BuildContext context) {
    var pages = widget.tabPages.call(tabs);
    return Row(children: [
      ModelList(
          action: widget.action,
          mapToDataModelItem: widget.mapToDataModelItem,
          selectedItem: widget.selectedItem,
          openFunction: widget.openFunction,
          mapToDeleteDialog: widget.mapToDeleteDialog,
          mapToDeleteSuccessfully: widget.mapToDeleteSuccessfully,
          converter: widget.converter,
      ),
      DefaultTabController(
          length: pages.length,
          child: Expanded(
            child: Scaffold(
              appBar: AppBar(
                toolbarHeight: 0,
                bottom: TabBar(
                  tabs: pages,
                ),
              ),
              body: TabBarView(
                children: pages.map((e) {
                  var text = e.child as Text;
                  return widget.page(
                      transform(text.data!), widget.selectedItem);
                }).toList(),
              ),
            ),
          ))
    ]);
  }

  TabPage transform(String name) {
    if (identical(TabPage.general.content, name)) {
      return TabPage.general;
    }

    if (identical(TabPage.meta.content, name)) {
      return TabPage.meta;
    }

    return TabPage.general;
  }
}
