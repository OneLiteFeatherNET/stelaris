import 'package:flutter/material.dart';
import 'package:stelaris/api/model/sound/sound_file_source.dart';
import 'package:stelaris/feature/sound/card/folder_icon.dart';
import 'package:stelaris/feature/sound/card/small_file_card.dart';
import 'package:stelaris/feature/sound/modal/sound_file_modal.dart';

class SoundFileCard extends StatelessWidget {
  const SoundFileCard({required this.eventModel, super.key});

  final SoundFileSource eventModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // If the card is too narrow, show only the icon centered in a card
        if (constraints.maxWidth < 230) {
          return const SmallFileCard();
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
                const FolderIcon(),
                const SizedBox(width: 12),
                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventModel.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        eventModel.name,
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
                      builder: (context) => SoundFileModal(
                        create: false,
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