import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/typedefs.dart';

const cancelText = Text("Cancel");
const yesText = Text("Yes");

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
          child: yesText,
          onPressed: () {
            if (successfully(value)) {
              Navigator.of(context).pop(true);
            }
          },
        ),
        TextButton(
            child: cancelText,
            onPressed: () {
              Navigator.of(context).pop(false);
            }
        ),
      ],
    );
  }
}