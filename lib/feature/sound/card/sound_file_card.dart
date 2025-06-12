import 'package:flutter/material.dart';
import 'package:stelaris/feature/sound/modal/edit_modal_dialog.dart';

class SoundFileCard extends StatelessWidget {
  const SoundFileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // If the card is too narrow, show only the icon centered in a card
        if (constraints.maxWidth < 250) {
          return Card(
            color: theme.colorScheme.surface,
            surfaceTintColor: theme.colorScheme.surfaceTint,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => SoundEditDialog(
                    onSave: ({
                      required volume,
                      required pitch,
                      required weight,
                      required stream,
                      required attenuationDistance,
                      required preload,
                      required type,
                    }) {
                      // Handle save logic here
                    },
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.folder,
                      color: theme.colorScheme.onSecondaryContainer,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        // Otherwise, show the full card layout
        return Card(
          color: theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Folder Icon
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.folder,
                    color: theme.colorScheme.onSecondaryContainer,
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
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Description of Sub-Module A',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
                    showDialog(
                      context: context,
                      builder: (context) => SoundEditDialog(
                        onSave: ({
                          required volume,
                          required pitch,
                          required weight,
                          required stream,
                          required attenuationDistance,
                          required preload,
                          required type,
                        }) {
                          // Handle save logic here
                        },
                      ),
                    );
                  },
                  child: const Text('View'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}