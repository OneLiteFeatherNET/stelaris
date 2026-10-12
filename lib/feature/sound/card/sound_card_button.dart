import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/sound/modal/sound_file_modal_helper.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The [SoundCardButton] is a widget that displays a specific button on a sound card which triggers a dialog to view sound file details.
/// A tonal button, in the secondary container colors of the theme.
class SoundCardButton extends StatelessWidget {
  const SoundCardButton({required this.source, super.key});

  final SoundFileSource source;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: () =>
          showSoundFileModal(context: context, create: false, source: source),
      child: Text(context.l10n.button_view),
    );
  }
}
