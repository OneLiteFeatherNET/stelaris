import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/base/button/cancel_button.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class ItemGroupChangeDialog extends StatelessWidget {
  final Text title;
  final List<TextSpan> header;
  final MapToDeleteSuccessfully function;

  const ItemGroupChangeDialog({
    super.key,
    required this.title,
    required this.header,
    required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: RichText(
        text: TextSpan(children: header),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(context.l10n.button_yes),
          onPressed: () {
            function(true);
            Navigator.of(context).pop(true);
          },
        ),
        const CancelButton(),
      ],
    );
  }
}
