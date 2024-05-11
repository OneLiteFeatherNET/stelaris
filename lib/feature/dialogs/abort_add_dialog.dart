import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/l10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class AbortAddDialog extends StatelessWidget {
  final String title;
  final String content;

  const AbortAddDialog({
    required this.title,
    required this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: dialogPadding,
      title: Text(
        title,
        textAlign: TextAlign.center,
      ),
      children: [
        Text(
          content,
          textAlign: TextAlign.center,
        ),
        verticalSpacing10,
        TextButton(
          autofocus: true,
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(context.l10n.button_ok),
        )
      ],
    );
  }
}
