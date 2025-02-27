import 'package:flutter/material.dart';

class EnchantmentActions extends StatelessWidget {
  const EnchantmentActions({
    required this.resetFunction,
    required this.saveFunction,
    required this.isDeleteMode,
    required this.onDeleteModeChanged,
    required this.onAddPressed,
    required this.hasEnchantments,
    required this.canAddMoreEnchantments,
    super.key,
  });

  final VoidCallback resetFunction;
  final VoidCallback saveFunction;
  final VoidCallback onAddPressed;
  final bool isDeleteMode;
  final ValueChanged<bool> onDeleteModeChanged;
  final bool hasEnchantments;
  final bool canAddMoreEnchantments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Add button
            FilledButton.tonalIcon(
              // Disable Add button when in delete mode
              onPressed: (canAddMoreEnchantments && !isDeleteMode) ? onAddPressed : null,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return theme.colorScheme.surfaceContainerHighest;
                  }
                  return theme.colorScheme.primaryContainer;
                }),
                foregroundColor:
                    WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return theme.colorScheme.onSurface.withValues(alpha: 0.38);
                  }
                  return theme.colorScheme.onPrimaryContainer;
                }),
              ),
            ),

            // Reset button
            FilledButton.tonalIcon(
              onPressed: hasEnchantments ? resetFunction : null,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Reset'),
            ),

            // Delete mode toggle
            FilledButton.tonalIcon(
              onPressed: hasEnchantments
                  ? () => onDeleteModeChanged(!isDeleteMode)
                  : null,
              icon: Icon(
                isDeleteMode ? Icons.delete_forever : Icons.delete_outline,
              ),
              label: Text(
                isDeleteMode ? 'Exit Delete Mode' : 'Delete Mode',
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(WidgetState.disabled)) {
                      return theme.colorScheme.surfaceContainerHighest;
                    }
                    if (isDeleteMode && hasEnchantments) {
                      return theme.colorScheme.errorContainer;
                    }
                    return theme.colorScheme.secondaryContainer;
                  },
                ),
              ),
            ),

            // Save button
            FilledButton.icon(
              onPressed: saveFunction,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
