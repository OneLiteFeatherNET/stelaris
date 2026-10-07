import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/sound/selected_sound_state.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/property/property_grid.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';

/// The sound's General tab: its key and subtitle.
class SoundGeneralPage extends StatelessWidget {
  const SoundGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedSoundView>(
      vm: () => SelectedSoundState(),
      builder: (context, vm) {
        final sound = vm.selected;
        String? required(String? value) =>
            checkIfEmptyAndReturnErrorString(value ?? emptyString, context);
        return PropertyGrid(
          properties: [
            TextProperty(
              label: context.l10n.sound_key,
              value: sound.keyName ?? emptyString,
              // A resource location, e.g. `entity.player.hurt` or
              // `custom:ui/click`.
              validator: (value) =>
                  required(value) ??
                  Validators.pattern(
                    adventureKeyPattern,
                    context.l10n.validation_sound_key_invalid,
                  )(value),
              onChanged: (value) => context.dispatch(
                UpdateSoundAction(sound.copyWith(keyName: value)),
              ),
            ),
            TextProperty(
              label: context.l10n.sound_subtitle,
              value: sound.subTitle ?? emptyString,
              validator: required,
              onChanged: (value) => context.dispatch(
                UpdateSoundAction(sound.copyWith(subTitle: value)),
              ),
            ),
          ],
        );
      },
    );
  }
}
