import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/feature/base/model_list.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class ModelContainerList<E extends DataModel> extends StatelessWidget {
  final MapToDataModelItem<E> mapToDataModelItem;
  final VoidCallback openFunction;
  final E? selectedItem;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final Function(E) callFunction;
  final List<E> models;

  const ModelContainerList({
    required this.mapToDataModelItem,
    required this.openFunction,
    required this.selectedItem,
    required this.mapToDeleteSuccessfully,
    required this.mapToDeleteDialog,
    required this.callFunction,
    required this.models,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ModelList(
      mapToDataModelItem: mapToDataModelItem,
      selectedItem: selectedItem,
      openFunction: openFunction,
      mapToDeleteDialog: mapToDeleteDialog,
      mapToDeleteSuccessfully: mapToDeleteSuccessfully,
      callFunction: callFunction,
      models: models,
    );
  }
}
