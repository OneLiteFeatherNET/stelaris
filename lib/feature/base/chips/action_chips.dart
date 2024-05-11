import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/l10n_ext.dart';

class ActionChips extends StatelessWidget {
  const ActionChips({
    required this.addFunction,
    required this.saveFunction,
    super.key,
  });

  final Function addFunction;
  final Function saveFunction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ActionChip(
          avatar: const Icon(Icons.add),
          label: Text(context.l10n.button_add),
          onPressed: () => addFunction(),
        ),
        const SizedBox(width: 50),
        FilledButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Save'),
          onPressed: () => saveFunction(),
        ),
      ],
    );
  }
}
