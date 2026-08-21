import 'package:flutter/material.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/sound/card/folder_icon.dart';
import 'package:stelaris/feature/sound/card/small_file_card.dart';
import 'package:stelaris/feature/sound/card/sound_card_button.dart';

class SoundFileCard extends StatelessWidget {
  static const double _fullCardMinWidth = 230;

  const SoundFileCard({
    required this.source,
    this.onDeleteRequested,
    super.key,
  });

  final SoundFileSource source;
  final VoidCallback? onDeleteRequested;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // If the card is too narrow, show only the icon centered in a card
        if (constraints.maxWidth < _fullCardMinWidth) {
          return SmallFileCard(fileSource: source);
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        source.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SoundCardButton(source: source),
                const SizedBox(width: 8),
                if (onDeleteRequested != null)
                  OutlinedButton(
                    onPressed: onDeleteRequested,
                    child: const Text('Delete'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
