import 'package:flutter/material.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/sound/modal/sound_file_modal_helper.dart';

/// The [SoundCardButton] is a widget that displays a specific button on a sound card which triggers a dialog to view sound file details.
/// It is styled with the theme's secondary container colors and has a rounded rectangle shape.
class SoundCardButton extends StatelessWidget {
  const SoundCardButton({required this.source, super.key});

  final SoundFileSource source;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.secondaryContainer,
        foregroundColor: theme.colorScheme.onSecondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: () =>
          showSoundFileModal(context: context, create: false, source: source),
      child: const Text('View'),
    );
  }
}
