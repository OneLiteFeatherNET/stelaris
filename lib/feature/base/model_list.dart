import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/feature/dialogs/dismiss_dialog.dart';

typedef MapToDataModelItem<E extends DataModel> = Widget Function(E value);

class ModelList<E extends DataModel> extends StatefulWidget {
  final List<E> items;
  final MapToDataModelItem<E> mapToDataModelItem;
  final ValueNotifier<E?> selectedItem;

  const ModelList(
      {Key? key,
      required this.items,
      required this.mapToDataModelItem,
      required this.selectedItem})
      : super(key: key);

  @override
  State<ModelList> createState() =>
      _ModelListState(items, mapToDataModelItem, selectedItem);
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
      child: Stack(
        children: [
          Expanded(
              child: SizedBox(
            width: 250,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: ListView(
                children: List<Widget>.generate(_items.length, (index) {
                  final e = _items[index];
                  final selected = e.hashCode == selectedItem.value.hashCode;
                  final selectedCardShape = RoundedRectangleBorder(
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.secondary), borderRadius: BorderRadius.circular(12.0));
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedItem.value = e;
                      });
                    },
                    child: Card(
                      shape: selected ? selectedCardShape : null,
                      child: ListTile(
                        title: mapToDataModelItem(e),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return DeleteDialog("header", context)
                                      .getDeleteDialog();
                                });
                          },
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          )),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: FloatingActionButton.extended(
                label: Text("Add"), icon: Icon(Icons.add), onPressed: () {}),
          )
        ],
      ),
    );
  }
}
