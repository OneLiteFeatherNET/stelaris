import 'package:flutter/material.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';

class AbortAddDialog extends StatelessWidget {
  const AbortAddDialog({
    required this.title,
    required this.content,
    super.key,
  });

  final String title;
  final String content;

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
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.button_ok),
        )
      ],
    );
  }
}
