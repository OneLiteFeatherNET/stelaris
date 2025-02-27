import 'package:flutter/material.dart';
import 'package:stelaris/api/model/data_model.dart';
import 'package:stelaris/feature/base/base_model_view.dart';
import 'package:stelaris/feature/base/model_content_tab_page.dart';
import 'package:stelaris/util/typedefs.dart';

/// A widget that combines a model list with tabbed content view.
///
/// This widget provides a consistent layout for displaying a list of models
/// alongside tabbed content related to the selected model.
class BaseModelViewTabs<E extends DataModel> extends StatelessWidget {
  const BaseModelViewTabs({
    required this.mapToDataModelItem,
    required this.openFunction,
    required this.selectedItem,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.callFunction,
    required this.models,
    required this.compareFunction,
    required this.page,
    required this.tabPages,
    required this.tabs,
    super.key,
  });

  final MapToDataModelItem<E> mapToDataModelItem;
  final VoidCallback openFunction;
  final E? selectedItem;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final Function(E) callFunction;
  final List<E> models;
  final bool Function(E) compareFunction;
  final TabMapFunction<E> page;
  final MapToTabPages tabPages;
  final List<Tab> tabs;

  @override
  Widget build(BuildContext context) {
    return BaseModelView(
      mapToDataModelItem: mapToDataModelItem,
      openFunction: openFunction,
      selectedItem: selectedItem,
      mapToDeleteDialog: mapToDeleteDialog,
      mapToDeleteSuccessfully: mapToDeleteSuccessfully,
      callFunction: callFunction,
      models: models,
      compareFunction: compareFunction,
      child: Expanded(
        child: ModelContentTabPage(
          selectedItem: selectedItem,
          page: page,
          tabPages: tabPages,
          tabs: tabs,
        ),
      ),
    );
  }
}
