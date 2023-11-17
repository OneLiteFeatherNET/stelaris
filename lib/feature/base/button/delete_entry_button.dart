import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/dialogs/delete_dialog.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class DeleteEntryButton<E> extends StatelessWidget {
  final String title;
  final List<TextSpan> header;
  final E value;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;

  const DeleteEntryButton(
      {super.key,
      required this.title,
      required this.header,
      required this.value,
      required this.mapToDeleteSuccessfully});

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
                    title,
                    textAlign: TextAlign.center,
                  ),
                  header: header,
                  value: value,
                  successfully: mapToDeleteSuccessfully);
            });
      },
    );
  }
}
