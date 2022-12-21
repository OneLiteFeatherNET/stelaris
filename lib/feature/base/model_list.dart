import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/feature/base/button/add_button.dart';
import 'package:stelaris_ui/feature/dialogs/dismiss_dialog.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class ModelList<E extends DataModel> extends StatefulWidget {
  final List<E> items;
  final MapToDataModelItem<E> mapToDataModelItem;
  final ValueNotifier<E?> selectedItem;
  final VoidCallback openFunction;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;

  const ModelList({
    Key? key,
    required this.items,
    required this.mapToDataModelItem,
    required this.selectedItem,
    required this.openFunction,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully
  }) : super(key: key);

  @override
  State<ModelList<E>> createState() => _ModelListState<E>();
}

class _ModelListState<E extends DataModel> extends State<ModelList<E>> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Stack(
        children: [
          SizedBox(
            width: 250,
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final e = widget.items[index];
                      final selected = e.hashCode == widget.selectedItem.value.hashCode;
                      final selectedCardShape = RoundedRectangleBorder(
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.secondary), borderRadius: BorderRadius.circular(12.0));
                      return InkWell(
                        onTap: () {
                          setState(() {
                            widget.selectedItem.value = e;
                          });
                        },
                        child: Card(
                          shape: selected ? selectedCardShape : null,
                          child: ListTile(
                            title: widget.mapToDataModelItem(e),
                            trailing: IconButton(
                              icon: deleteIcon,
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return DeleteDialog(
                                          widget.mapToDeleteDialog(e), context, e, widget.mapToDeleteSuccessfully)
                                          .getDeleteDialog();
                                    });
                              },
                            ),
                          ),
                        ),
                      );
                    }
                )
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: AddButton(
              openFunction: widget.openFunction,
            ),
          )
        ],
      ),
    );
  }
}
