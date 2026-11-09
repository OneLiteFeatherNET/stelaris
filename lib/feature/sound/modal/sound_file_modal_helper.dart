import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/sound/sound_file_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/picker/asset_key.dart';
import 'package:stelaris/feature/asset/picker/asset_picker_dialog.dart';
import 'package:stelaris/feature/asset/picker/pick_asset_file.dart';
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
  final state = StoreProvider.state<AppState>(context);
  final project = state.selectedProject;
  final projectId = project?.id;
  showDialog(
    context: context,
    builder: (dialogContext) => SoundFileModal(
      initialData: source,
      create: create,
      pickSound: projectId == null
          ? null
          : (context, selectedKey) => showAssetPickerDialog(
              context,
              projectId: projectId,
              namespace: project!.key,
              selectedKey: selectedKey,
              kinds: soundAssetKinds,
              uploadKinds: soundAssetKinds,
              keyFolder: soundKeyFolder(state.selectedSoundEvent?.key),
              replaceable: true,
              pickFile: () => pickAssetFile(accept: '.ogg'),
            ),
      onSave: (soundFile) {
        final action = create
            ? SoundFileLinkAction(soundFile)
            : SoundFileUpdateAction(soundFile);
        dialogContext.dispatch(action);
      },
    ),
  );
}

/// The folder a sound uploaded for the event [eventKey] is suggested under:
/// the first part of the key, as Minecraft sorts its sounds, e.g. `ui` for
/// `ui.button.click`, or `sound` without one.
String soundKeyFolder(String? eventKey) {
  final path = eventKey?.split(':').last ?? '';
  final first = path.split('.').first.toLowerCase();
  return RegExp(r'^[a-z0-9_-]+$').hasMatch(first) ? first : 'sound';
}
