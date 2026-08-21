import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/sound/sound_file_actions.dart';
import 'package:stelaris/feature/sound/modal/sound_file_modal.dart';

/// Displays a modal dialog for creating or updating a [SoundFileSource].
///
/// This function simplifies showing the [SoundFileModal] and handles dispatching
/// the correct Redux action when the user saves. If [create] is true, it dispatches
/// a [SoundFileLinkAction] to add a new file. Otherwise, it dispatches a
/// [SoundFileUpdateAction] to modify an existing one.
///
/// - [context]: The build context from which to launch the dialog.
/// - [create]: A boolean that determines whether the modal is for creating a new file.
/// - [source]: The initial [SoundFileSource] data, typically provided when updating an existing file.
void showSoundFileModal({
  required BuildContext context,
  required bool create,
  SoundFileSource? source,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => SoundFileModal(
      initialData: source,
      create: create,
      onSave: (soundFile) {
        final action = create
            ? SoundFileLinkAction(soundFile)
            : SoundFileUpdateAction(soundFile);
        dialogContext.dispatch(action);
      },
    ),
  );
}
