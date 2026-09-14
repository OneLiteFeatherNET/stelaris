import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/button/delete_model_button.dart';
import 'package:stelaris/util/typedefs.dart';

class ModelCard<E extends DataModel> extends StatelessWidget {
  const ModelCard({
    required this.selected,
    required this.selectedCardShape,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.mapToDataModelItem,
    required this.rawModel,
    this.onTap,
    super.key,
  });

  final bool selected;
  final RoundedRectangleBorder selectedCardShape;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final MapToDataModelItem<E> mapToDataModelItem;
  final E rawModel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = selectedCardShape.borderRadius;

    return FractionallySizedBox(
      widthFactor: 0.90,
      child: Card(
        shape: selected ? selectedCardShape : null,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          hoverColor: colorScheme.secondary.withValues(alpha: 0.1),
          onTap: onTap,
          title: mapToDataModelItem(rawModel),
          trailing: DeleteModelButton<E>(
            value: rawModel,
            mapToDeleteDialog: mapToDeleteDialog,
            mapToDeleteSuccessfully: mapToDeleteSuccessfully,
          ),
        ),
      ),
    );
  }
}
