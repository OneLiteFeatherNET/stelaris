import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: Text(context.l10n.button_cancel),
        onPressed: () {
          Navigator.of(context).pop(false);
        }
    );
  }
}
