import 'package:flutter/material.dart';
import 'package:stelaris/api/model/data_model.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/typedefs.dart';

class ModelContentTabPage<E extends DataModel> extends StatelessWidget {
  const ModelContentTabPage({
    required this.selectedItem,
    required this.tabPages,
    required this.page,
    required this.tabs,
    super.key,
  });

  final E? selectedItem;
  final MapToTabPages tabPages;
  final TabMapFunction<E> page;
  final List<Tab> tabs;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      animationDuration: const Duration(milliseconds: 300),
      length: tabs.length,
      initialIndex: 0,
      child: Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 0,
              bottom: TabBar(
                tabs: tabs,
              ),
            ),
            body: TabBarView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: tabs.map(
                (element) {
                  final Text text = element.child as Text;
                  return page(
                    text.data ?? emptyString,
                    selectedItem,
                  );
                },
              ).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
