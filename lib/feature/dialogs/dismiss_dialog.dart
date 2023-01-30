import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class DeleteDialog<E> {

  Text title;
  List<TextSpan> header;
  BuildContext context;
  final E value;
  final MapToDeleteSuccessfully<E> successfully;

  DeleteDialog({required this.title, required this.header, required this.context, required this.value, required this.successfully});

  AlertDialog getDeleteDialog() {
    return AlertDialog(
      title: title,
      content: RichText(
        text: TextSpan(
          children: header
        ),
      ),
      actions: <Widget> [
        TextButton(
          child: Text(context.l10n.button_yes),
          onPressed: () {
            if (successfully(value)) {
              Navigator.of(context).pop(true);
            }
          },
        ),
        TextButton(
            child: Text(context.l10n.button_cancel),
            onPressed: () {
              Navigator.of(context).pop(false);
            }
        ),
      ],
    );
  }
}