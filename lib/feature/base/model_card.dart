import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/feature/base/button/delete_model_button.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class ModelCard<E extends DataModel> extends StatelessWidget {
  final bool selected;
  final RoundedRectangleBorder selectedCardShape;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final MapToDataModelItem<E> mapToDataModelItem;
  final E rawModel;

  const ModelCard({
    super.key,
    required this.selected,
    required this.selectedCardShape,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.mapToDataModelItem,
    required this.rawModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: selected ? selectedCardShape : null,
      child: ListTile(
        title: mapToDataModelItem(rawModel),
        trailing: DeleteModelButton<E>(
          value: rawModel,
          mapToDeleteDialog: mapToDeleteDialog,
          mapToDeleteSuccessfully: mapToDeleteSuccessfully,
        ),
      ),
    );
  }
}
