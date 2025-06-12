import 'package:flutter/material.dart';

class SoundFileCard extends StatelessWidget {
  const SoundFileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface, // uses theme surface color
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      elevation: 1, // Material 3 prefers low elevation + tint
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Folder Icon
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                // secondary container color
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.folder,
                color: theme.colorScheme.onSecondaryContainer,
                // adaptive icon color
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sub-Module A',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface, // primary text color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Description of Sub-Module A',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant, // secondary text
                    ),
                  ),
                ],
              ),
            ),

            // "View" Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onPressed: () {
                // Action here
              },
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }
}
