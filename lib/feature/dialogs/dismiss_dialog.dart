import 'package:flutter/material.dart';

const deleteTitle = Text("Are you sure to delete that entry?");
const cancelText = Text("Cancel");
const yesText = Text("Yes");

class DeleteDialog {

  List<TextSpan> header;
  BuildContext context;

  DeleteDialog(this.header, this.context);

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
            Navigator.of(context).pop(true);
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