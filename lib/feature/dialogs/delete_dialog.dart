import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/base/button/cancel_button.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class DeleteDialog<E> extends StatelessWidget {
  final Text title;
  final List<TextSpan> header;
  final E value;
  final MapToDeleteSuccessfully<E> successfully;

  const DeleteDialog({
    required this.title,
    required this.header,
    required this.value,
    required this.successfully,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: dialogPadding,
      title: title,
      content: RichText(
        text: TextSpan(children: header),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(context.l10n.button_yes),
          onPressed: () {
            if (successfully(value)) {
              Navigator.of(context).pop(true);
            }
          },
        ),
        const CancelButton(),
      ],
    );
  }
}
