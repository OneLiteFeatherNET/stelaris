import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/feature/base/model_search_add.dart';
import 'package:stelaris_ui/feature/dialogs/dismiss_dialog.dart';

typedef MapToDataModelItem<E extends DataModel> = Widget Function(E value);

class ModelList<E extends DataModel> extends StatefulWidget {

  final List<E> items;
  final MapToDataModelItem<E> mapToDataModelItem;
  final ValueNotifier<E?> selectedItem;

  const ModelList({Key? key, required this.items, required this.mapToDataModelItem, required this.selectedItem}) : super(key: key);

  @override
  State<ModelList> createState() => _ModelListState(items, mapToDataModelItem, selectedItem);
}

class _ModelListState<E extends DataModel> extends State<ModelList> {

  final List<E> _items;
  final MapToDataModelItem<E> mapToDataModelItem;
  final ValueNotifier<E?> selectedItem;

  _ModelListState(this._items, this.mapToDataModelItem, this.selectedItem);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          const ModelSearchAddControl(),
          Expanded(
              child: SizedBox(
                width: 250,
                child: ListView(
                    children: _items
                        .map((e) =>
                        TextButton(
                          onPressed: () {
                            selectedItem.value = e;
                      },
                      child: Dismissible(
                          direction: DismissDirection.endToStart,
                          movementDuration:
                          const Duration(milliseconds: 500),
                          background: Container(color: Colors.green),
                          confirmDismiss: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              return showDialog(context: context, builder: (BuildContext context) {
                                return DeleteDialog("header", context).getDeleteDialog();
                              });
                            } else {
                              var dismiss = Future.value(true);
                              return dismiss;
                            }
                          },
                          secondaryBackground: Container(
                            padding: const EdgeInsets.only(right: 15),
                            alignment: Alignment.centerRight,
                            color: Colors.red,
                            child: const Icon(Icons.cancel,
                                color: Colors.white),
                          ),
                          key: const Key("test"),
                          child: Card(
                              child: ListTile(
                                title: mapToDataModelItem(e),
                              )
                          )
                      ),
                    )).toList()
                ),
              )
          ),
        ],
      ),
    );
  }
}
