import 'package:flutter/material.dart';

/// The [FolderIcon] is a widget that displays a folder icon in the center of a container.
/// It is styled with padding, margin, and a background color that matches the theme's secondary container.
class FolderIcon extends StatelessWidget {
  const FolderIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.folder,
        color: theme.colorScheme.onSecondaryContainer,
        size: 28,
      ),
    );
  }
}
