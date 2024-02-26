import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/feature/base/base_model_view.dart';
import 'package:stelaris_ui/feature/base/model_content_tab_page.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class BaseModelViewTabs<E extends DataModel> extends StatelessWidget {

  final MapToDataModelItem<E> mapToDataModelItem;
  final VoidCallback openFunction;
  final E? selectedItem;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final Function(E) callFunction;
  final TabPageMapFunction<E> page;
  final MapToTabPages tabPages;
  final List<E> models;
  final bool Function(E) compareFunction;

  const BaseModelViewTabs({
    required this.mapToDataModelItem,
    required this.openFunction,
    required this.selectedItem,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.callFunction,
    required this.page,
    required this.tabPages,
    required this.models,
    required this.compareFunction,
    super.key
  });

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
      child: ModelContentTabPage(
        selectedItem: selectedItem,
        page: page,
        tabPages: tabPages,
      ),
    );
  }
}
