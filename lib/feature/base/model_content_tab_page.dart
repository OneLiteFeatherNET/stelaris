import 'package:flutter/material.dart';
import 'package:stelaris/api/model/data_model.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/typedefs.dart';

/// A widget that displays tab-based content for a data model.
///
/// [E] represents the type of data model being displayed.
/// [selectedItem] is the currently selected model item.
/// [tabPages] defines how pages are mapped to tabs.
/// [page] is a function that creates content for each tab.
/// [tabs] is the list of tabs to display.
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DefaultTabController(
        length: tabs.length,
        initialIndex: 0,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AppBar(
              toolbarHeight: 0,
              bottom: TabBar(tabs: tabs),
            ),
          ),
          body: TabBarView(
            children: _buildTabPages(),
          ),
        ),
      ),
    );
  }

  /// Builds the tab pages based on the provided tabs.
  List<Widget> _buildTabPages() {
    return tabs.map((tab) {
      if (tab.child is! Text) {
        throw StateError('Tab child must be a Text widget');
      }
      final text = (tab.child as Text).data ?? emptyString;
      return page(text, selectedItem);
    }).toList();
  }
}
