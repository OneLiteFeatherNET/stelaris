import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/paginated_model_list.dart';
import 'package:stelaris/util/typedefs.dart';

class BaseModelView<E extends DataModel> extends StatelessWidget {
  const BaseModelView({
    required this.mapToDataModelItem,
    required this.openFunction,
    required this.selectedItem,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.callFunction,
    required this.models,
    required this.child,
    required this.compareFunction,
    super.key,
  });

  final MapToDataModelItem<E> mapToDataModelItem;
  final VoidCallback openFunction;
  final E? selectedItem;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final Function(E) callFunction;
  final List<E> models;
  final Widget? child;
  final bool Function(E) compareFunction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaginatedModelList(
          mapToDataModelItem: mapToDataModelItem,
          openFunction: openFunction,
          selectedItem: selectedItem,
          mapToDeleteDialog: mapToDeleteDialog,
          mapToDeleteSuccessfully: mapToDeleteSuccessfully,
          callFunction: callFunction,
          models: models,
          compareFunction: compareFunction,
        ),
        ?child,
      ],
    );
  }
}
