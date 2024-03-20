import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class InfoButton extends StatelessWidget {
  const InfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.text_wiki),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Copy',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Clipboard.setData(const ClipboardData(text: conceptURL));
              },
            ),
            width: 550.0,
            elevation: 0.0,
          ),
        );
      },
      icon: const Icon(Icons.help_outline),
    );
  }
}
