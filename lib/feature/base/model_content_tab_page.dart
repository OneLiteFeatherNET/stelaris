import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/util/typedefs.dart';

const List<TabPage> tabPagesValues = TabPage.values;
List<Tab> tabs = tabPagesValues
    .map((e) => Tab(
          child: Text(e.content),
        ))
    .toList();

class ModelContentTabPage<E extends DataModel> extends StatelessWidget {
  final E? selectedItem;
  final MapToTabPages tabPages;
  final TabPageMapFunction<E> page;

  const ModelContentTabPage({
    super.key,
    this.selectedItem,
    required this.tabPages,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    var pages = tabPages.call(tabs);
    return DefaultTabController(
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
            children: pages.map(
              (e) {
                var text = e.child as Text;
                return page(
                  transform(text.data!),
                  selectedItem,
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
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
