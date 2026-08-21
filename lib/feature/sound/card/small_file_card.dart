import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/sound/card/folder_icon.dart';
import 'package:stelaris/feature/sound/modal/sound_file_modal_helper.dart';

class SmallFileCard extends StatelessWidget {
  const SmallFileCard({required this.fileSource, super.key});

  final SoundFileSource fileSource;

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
        onTap: () => showSoundFileModal(
          context: context,
          create: false,
          source: fileSource,
        ),
        child: const FolderIcon(),
      ),
    );
  }
}
