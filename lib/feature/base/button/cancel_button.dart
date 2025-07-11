import 'package:flutter/material.dart';
import 'package:stelaris/util/l10n_ext.dart';

class CancelButton extends StatelessWidget {
  const CancelButton({this.callback, super.key});

  final VoidCallback? callback;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(context.l10n.button_cancel),
      onPressed: () {
        Navigator.of(context).pop(false);
        callback?.call();
      },
    );
  }
}
