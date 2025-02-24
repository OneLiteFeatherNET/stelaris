import 'package:flutter/material.dart';
import 'package:stelaris/api/model/data_model.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/typedefs.dart';

class DeleteModelButton<E extends DataModel> extends StatelessWidget {
  const DeleteModelButton({
    required this.value,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    super.key,
  });

  final E value;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;

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
