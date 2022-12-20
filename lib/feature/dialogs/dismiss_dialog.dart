import 'package:flutter/material.dart';

const deleteTitle = Text("Are you sure to delete that entry?");
const cancelText = Text("Cancel");
const yesText = Text("Yes");


typedef MapToDeleteSuccessfully<E> = bool Function(E value);

class DeleteDialog<E> {

  List<TextSpan> header;
  BuildContext context;
  final E value;
  final MapToDeleteSuccessfully<E> successfully;

  DeleteDialog(this.header, this.context, this.value, this.successfully);

  AlertDialog getDeleteDialog() {
    return AlertDialog(
      title: deleteTitle,
      content: RichText(
        text: TextSpan(
          children: header
        ),
      ),
      actions: <Widget> [
        TextButton(
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Colors.red,
          ),
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