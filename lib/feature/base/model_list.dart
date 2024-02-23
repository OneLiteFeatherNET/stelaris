import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/feature/base/button/add_button.dart';
import 'package:stelaris_ui/feature/base/model_card.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class ModelList<E extends DataModel> extends StatelessWidget {
  final MapToDataModelItem<E> mapToDataModelItem;
  final E? selectedItem;
  final VoidCallback openFunction;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final Function(E) callFunction;
  final List<E> models;

  const ModelList({
    required this.mapToDataModelItem,
    required this.selectedItem,
    required this.openFunction,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.callFunction,
    required this.models,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 250,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: models.length,
              itemBuilder: (context, index) {
                final E rawModel = models[index];
                final selected = rawModel.hashCode == selectedItem.hashCode;
                final selectedCardShape = RoundedRectangleBorder(
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                  borderRadius: BorderRadius.circular(12.0),
                );
                return GestureDetector(
                  onTap: () {
                    callFunction.call(rawModel);
                  },
                  child: ModelCard<E>(
                    selected: selected,
                    selectedCardShape: selectedCardShape,
                    mapToDeleteDialog: mapToDeleteDialog,
                    mapToDeleteSuccessfully: mapToDeleteSuccessfully,
                    mapToDataModelItem: mapToDataModelItem,
                    rawModel: rawModel,
                  ),
                );
              },
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: AddButton(openFunction: openFunction),
          ),
        )
      ],
    );
  }
}
