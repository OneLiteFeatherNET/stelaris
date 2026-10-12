import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/sound/selected_sound_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_card_grid.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/validators.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The sound event's General tab: its key and subtitle, each a card that
/// opens a dialog.
class SoundGeneralPage extends StatelessWidget {
  const SoundGeneralPage({super.key});

  /// Puts [sound] into the store and marks the page unsaved. The header's
  /// save sends it to the backend.
  static void _stage(BuildContext context, SoundEventModel sound) {
    context
      ..dispatch(UpdateSoundAction(sound))
      ..dispatch(MarkUnsavedChangesAction(NavigationEntry.sound));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedSoundView>(
      vm: () => SelectedSoundState(),
      builder: (context, vm) {
        final l10n = context.l10n;
        final sound = vm.selected;
        return EditCardGrid(
          sections: [
            EditSection(
              title: l10n.sound_section_general,
              fields: [
                TextEdit(
                  label: l10n.sound_key,
                  icon: Icons.key,
                  value: sound.keyName ?? emptyString,
                  footer: l10n.sound_hint_key,
                  validator: (value) =>
                      checkIfEmptyAndReturnErrorString(
                        value ?? emptyString,
                        context,
                      ) ??
                      Validators.pattern(
                        adventureKeyPattern,
                        l10n.validation_sound_key_invalid,
                      )(value),
                  onChanged: (value) =>
                      _stage(context, sound.copyWith(keyName: value)),
                ),
                TextEdit(
                  label: l10n.sound_subtitle,
                  icon: Icons.subtitles_outlined,
                  value: sound.subTitle ?? emptyString,
                  footer: l10n.sound_hint_subtitle,
                  validator: (value) => checkIfEmptyAndReturnErrorString(
                    value ?? emptyString,
                    context,
                  ),
                  onChanged: (value) =>
                      _stage(context, sound.copyWith(subTitle: value)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
