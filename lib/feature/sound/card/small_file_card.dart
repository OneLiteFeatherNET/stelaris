import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/sound/sound_file_source.dart';
import 'package:stelaris/api/state/actions/sound/sound_file_actions.dart';
import 'package:stelaris/feature/sound/card/folder_icon.dart';
import 'package:stelaris/feature/sound/modal/sound_file_modal.dart';

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
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => SoundFileModal(
              initialData: fileSource,
              create: false,
              onSave: (soundFile) =>
                  context.dispatch(SoundFileLinkAction(soundFile)),
            ),
          );
        },
        child: const FolderIcon(),
      ),
    );
  }
}
