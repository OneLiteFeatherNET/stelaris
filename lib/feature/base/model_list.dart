import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/base/button/add_button.dart';
import 'package:stelaris_ui/feature/base/button/delete_model_button.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class ModelList<E extends DataModel> extends StatefulWidget {
  final MapToDataModelItem<E> mapToDataModelItem;
  final ValueNotifier<E?> selectedItem;
  final VoidCallback openFunction;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final ReduxAction<AppState> action;
  final List<DataModel> Function(Store<AppState>) converter;

  const ModelList({
    required this.action,
    required this.mapToDataModelItem,
    required this.selectedItem,
    required this.openFunction,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.converter,
    super.key,
  });

  @override
  State<ModelList<E>> createState() => _ModelListState<E>();
}

class _ModelListState<E extends DataModel> extends State<ModelList<E>> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<DataModel>>(
      onInit: (store) {
        store.dispatch(widget.action);
      },
      converter: widget.converter,
      builder: (context, vm) {
        return Container(
          color: Theme.of(context).colorScheme.background,
          child: Stack(
            children: [
              SizedBox(
                width: 250,
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListView.builder(
                        itemCount: vm.length,
                        itemBuilder: (context, index) {
                          final E e = vm[index] as E;
                          final selected =
                              e.hashCode == widget.selectedItem.value.hashCode;
                          final selectedCardShape = RoundedRectangleBorder(
                              side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              borderRadius: BorderRadius.circular(12.0));
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
                                  trailing: DeleteModelButton<E>(
                                    value: e,
                                    mapToDeleteDialog: widget.mapToDeleteDialog,
                                    mapToDeleteSuccessfully:
                                        widget.mapToDeleteSuccessfully,
                                  )),
                            ),
                          );
                        })),
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
      },
    );
  }
}
