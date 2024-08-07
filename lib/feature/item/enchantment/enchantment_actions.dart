import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/constants.dart';

class EnchantmentActions extends StatelessWidget {
  const EnchantmentActions({
    required this.resetFunction,
    required this.saveFunction,
    super.key,
  });

  final Function() resetFunction;
  final Function() saveFunction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ActionChip(
          onPressed: () => resetFunction(),
          avatar: const Icon(Icons.refresh_sharp),
          label: const Text('Reset'),
        ),
        const SizedBox(width: fiftyLength),
        FilledButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Save'),
          onPressed: () => saveFunction()
        ),
      ],
    );
  }
}
