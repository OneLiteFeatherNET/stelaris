import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/base/model_container_list.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class BaseModelView<E extends DataModel> extends StatelessWidget {
  final ReduxAction<AppState> action;
  final MapToDataModelItem<E> mapToDataModelItem;
  final VoidCallback openFunction;
  final E? selectedItem;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final List<E> Function(Store<AppState>) converter;
  final Function(E) callFunction;
  final Widget? child;

  const BaseModelView({
    required this.action,
    required this.mapToDataModelItem,
    required this.openFunction,
    required this.selectedItem,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.converter,
    required this.callFunction,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModelContainerList(
          action: action,
          mapToDataModelItem: mapToDataModelItem,
          openFunction: openFunction,
          selectedItem: selectedItem,
          mapToDeleteDialog: mapToDeleteDialog,
          mapToDeleteSuccessfully: mapToDeleteSuccessfully,
          converter: converter,
          callFunction: callFunction,
        ),
        if (child != null) child!,
      ],
    );
  }
}
