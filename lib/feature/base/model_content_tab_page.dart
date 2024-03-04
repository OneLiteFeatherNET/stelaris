import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class ModelContentTabPage<E extends DataModel> extends StatelessWidget {
  final E? selectedItem;
  final MapToTabPages tabPages;
  final TabMapFunction<E> page;
  final List<Tab> tabs;

  const ModelContentTabPage({
    required this.selectedItem,
    required this.tabPages,
    required this.page,
    required this.tabs,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Expanded(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            bottom: TabBar(
              tabs: tabs,
            ),
          ),
          body: TabBarView(
            children: tabs.map(
              (e) {
                Text text = e.child as Text;
                return page(
                  text.data ?? emptyString,
                  selectedItem,
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}
