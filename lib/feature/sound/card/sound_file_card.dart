import 'package:flutter/material.dart';
import 'package:stelaris/api/model/sound/sound_file_source.dart';
import 'package:stelaris/feature/sound/card/folder_icon.dart';
import 'package:stelaris/feature/sound/card/small_file_card.dart';
import 'package:stelaris/feature/sound/card/sound_card_button.dart';

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
            padding: const EdgeInsets.only(right: 16),
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
                const SoundCardButton()
              ],
            ),
          ),
        );
      },
    );
  }
}