import 'package:flutter/material.dart';
import 'package:stelaris/api/model/data_model.dart';
import 'package:stelaris/feature/base/button/add_button.dart';
import 'package:stelaris/feature/base/model_card.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/typedefs.dart';

class ModelList<E extends DataModel> extends StatefulWidget {
  final MapToDataModelItem<E> mapToDataModelItem;
  final E? selectedItem;
  final VoidCallback openFunction;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final Function(E) callFunction;
  final List<E> models;
  final bool Function(E) compareFunction;

  const ModelList({
    required this.mapToDataModelItem,
    required this.selectedItem,
    required this.openFunction,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.callFunction,
    required this.models,
    required this.compareFunction,
    super.key,
  });

  @override
  State<ModelList<E>> createState() => _ModelListState<E>();
}

class _ModelListState<E extends DataModel> extends State<ModelList<E>> {

  final ScrollController _scrollController = ScrollController();
  
  // Cache the card shape to avoid rebuilds
  late final RoundedRectangleBorder _defaultCardShape;
  
  @override
  void initState() {
    super.initState();
    _defaultCardShape = RoundedRectangleBorder(
      side: BorderSide(color: Theme.of(context).colorScheme.secondary),
      borderRadius: BorderRadius.circular(12),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SizedBox(
            width: 250,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.models.length,
              addAutomaticKeepAlives: true,
              clipBehavior: Clip.none, // Reduce overdraw
              itemBuilder: (context, index) {
                final E rawModel = widget.models[index];
                return RepaintBoundary(
                  child: GestureDetector(
                    onTap: () => widget.callFunction.call(rawModel),
                    child: ModelCard<E>(
                      selected: widget.compareFunction.call(rawModel),
                      selectedCardShape: _defaultCardShape,
                      mapToDeleteDialog: widget.mapToDeleteDialog,
                      mapToDeleteSuccessfully: widget.mapToDeleteSuccessfully,
                      mapToDataModelItem: widget.mapToDataModelItem,
                      rawModel: rawModel,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        verticalSpacing10,
        SizedBox(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: AddButton(openFunction: widget.openFunction),
          ),
        )
      ],
    );
  }
}