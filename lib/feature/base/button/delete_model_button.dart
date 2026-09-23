import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/dialogs/model_delete_dialog.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/typedefs.dart';

class DeleteModelButton<E extends DataModel> extends StatelessWidget {
  const DeleteModelButton({
    required this.value,
    required this.deleteTitle,
    required this.name,
    required this.mapToDeleteSuccessfully,
    this.deleteWarning,
    this.namespacedKey,
    super.key,
  });

  final E value;
  final String deleteTitle;
  final String name;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final String? deleteWarning;
  final String? namespacedKey;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: deleteIcon,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return ModelDeleteDialog<E>(
              title: deleteTitle,
              name: name,
              value: value,
              successfully: mapToDeleteSuccessfully,
              namespacedKey: namespacedKey,
              warning: deleteWarning,
            );
          },
        );
      },
    );
  }
}
