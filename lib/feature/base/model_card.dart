import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/button/delete_model_button.dart';
import 'package:stelaris/feature/base/button/model_actions_menu.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/typedefs.dart';

class ModelCard<E extends DataModel> extends StatelessWidget {
  const ModelCard({
    required this.selected,
    required this.selectedCardShape,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.mapToDataModelItem,
    required this.rawModel,
    required this.nameSelector,
    required this.keySelector,
    required this.projectKey,
    this.hasRelationshipData,
    this.onTap,
    super.key,
  });

  final bool selected;
  final RoundedRectangleBorder selectedCardShape;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final MapToDataModelItem<E> mapToDataModelItem;
  final E rawModel;
  final ModelNameSelector<E> nameSelector;
  final ModelKeySelector<E> keySelector;
  final String projectKey;
  final HasRelationshipData<E>? hasRelationshipData;
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
        child: InkWell(
          key: const Key('model_card_inkwell'),
          borderRadius: borderRadius is BorderRadius ? borderRadius : null,
          customBorder: borderRadius is! BorderRadius
              ? RoundedRectangleBorder(borderRadius: borderRadius)
              : null,
          hoverColor: colorScheme.secondary.withValues(alpha: 0.1),
          splashFactory: NoSplash.splashFactory,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: mapToDataModelItem(rawModel),
                ),
                ModelActionsMenu<E>(
                  value: rawModel,
                  nameSelector: nameSelector,
                  keySelector: keySelector,
                  projectKey: projectKey,
                  hasRelationshipData: hasRelationshipData,
                ),
                DeleteModelButton<E>(
                  value: rawModel,
                  mapToDeleteDialog: mapToDeleteDialog,
                  mapToDeleteSuccessfully: mapToDeleteSuccessfully,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
