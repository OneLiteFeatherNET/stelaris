import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';

class TriggerDialog extends StatelessWidget {
  const TriggerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(context.l10n.text_trigger_title, textAlign: TextAlign.center,),
      contentPadding: const EdgeInsets.all(20.0),
      children: [
        TextButton(
            onPressed: () {},
            child: Text(context.l10n.button_trigger_go)
        )
      ],
    );
  }
}
