import 'package:flutter/material.dart';
import 'package:stelaris/feature/sound/card/folder_icon.dart';
import 'package:stelaris/feature/sound/modal/sound_file_modal.dart';

class SmallFileCard extends StatelessWidget {
  const SmallFileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
        child: const FolderIcon()
      ),
    );
  }
}
