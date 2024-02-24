import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/feature/base/button/delete_model_button.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class ModelCard<E extends DataModel> extends StatefulWidget {
  final bool selected;
  final RoundedRectangleBorder selectedCardShape;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final MapToDataModelItem<E> mapToDataModelItem;
  final E rawModel;

  const ModelCard({
    required this.selected,
    required this.selectedCardShape,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.mapToDataModelItem,
    required this.rawModel,
    super.key,
  });

  @override
  State<ModelCard> createState() => _ModelCardState<E>();
}

class _ModelCardState<E extends DataModel> extends State<ModelCard<E>> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: widget.selected ? widget.selectedCardShape : null,
      color: isHovered
          ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
          : null,
      child: MouseRegion(
        onEnter: (event) => _toggleHoverState(),
        onExit: (event) => _toggleHoverState(),
        child: ListTile(
          title: widget.mapToDataModelItem(widget.rawModel),
          trailing: DeleteModelButton<E>(
            value: widget.rawModel,
            mapToDeleteDialog: widget.mapToDeleteDialog,
            mapToDeleteSuccessfully: widget.mapToDeleteSuccessfully,
          ),
        ),
      ),
    );
  }

  /// Toggles the hover state of the card
  void _toggleHoverState() {
    setState(() {
      isHovered = !isHovered;
    });
  }
}
