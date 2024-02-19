import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/base/base_model_view.dart';
import 'package:stelaris_ui/feature/base/model_content_tab_page.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class BaseModelViewTabs<E extends DataModel> extends StatelessWidget {

  final ReduxAction<AppState> action;
  final MapToDataModelItem<E> mapToDataModelItem;
  final VoidCallback openFunction;
  final E? selectedItem;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final List<E> Function(Store<AppState>) converter;
  final Function(E) callFunction;
  final TabPageMapFunction<E> page;
  final MapToTabPages tabPages;

  const BaseModelViewTabs({
    required this.action,
    required this.mapToDataModelItem,
    required this.openFunction,
    required this.selectedItem,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.converter,
    required this.callFunction,
    required this.page,
    required this.tabPages,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return BaseModelView(
      action: action,
      mapToDataModelItem: mapToDataModelItem,
      openFunction: openFunction,
      selectedItem: selectedItem,
      mapToDeleteDialog: mapToDeleteDialog,
      mapToDeleteSuccessfully: mapToDeleteSuccessfully,
      converter: converter,
      callFunction: callFunction,
      child: ModelContentTabPage(
        selectedItem: selectedItem,
        page: page,
        tabPages: tabPages,
      ),
    );
  }
}
