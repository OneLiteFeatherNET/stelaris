import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/feature/dialogs/delete_dialog.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class DeleteModelButton<E extends DataModel> extends StatelessWidget {
  final E value;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;

  const DeleteModelButton({
    super.key,
    required this.value,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: deleteIcon,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return DeleteDialog<E>(
              title: Text(
                context.l10n.dialog_delete_confirm,
                textAlign: TextAlign.center,
              ),
              header: mapToDeleteDialog(value),
              value: value,
              successfully: mapToDeleteSuccessfully,
            );
          },
        );
      },
    );
  }
}
