import 'package:flutter/material.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';

class LoreConfirmWidget extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onSave;
  final bool isEditing;

  const LoreConfirmWidget({
    required this.onConfirm, required this.onSave, required this.isEditing, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return !isEditing
        ? ActionChip(
            label: Text(context.l10n.button_save),
            onPressed: onSave,
            avatar: saveIcon,
          )
        : FilledButton.icon(
            onPressed: onConfirm,
            icon: confirmIcon,
            label: const Text('Confirm'),
          );
  }
}
