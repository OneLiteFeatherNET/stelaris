import 'package:flutter/material.dart';

class EditActionChips extends StatelessWidget {
  const EditActionChips({
    required this.deleteConfirm,
    super.key,
  });

  final Function() deleteConfirm;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton.icon(
          label: const Text('Confirm'),
          onPressed: () => deleteConfirm(),
          icon: const Icon(Icons.check),
        ),
      ],
    );
  }
}
