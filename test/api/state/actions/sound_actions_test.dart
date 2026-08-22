import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('RemoveSelectedSoundEvent', () {
    test(
      'clears the selected sound event even when no font is selected',
      () {
        final store = Store<AppState>(
          initialState: const AppState().copyWith(
            selectedFont: null,
            selectedSoundEvent: SoundEventModel(uiName: 'boop'),
          ),
        );

        store.dispatchSync(RemoveSelectedSoundEvent());

        expect(store.state.selectedSoundEvent, isNull);
      },
    );

    test('is a no-op when no sound event is selected', () {
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedFont: const FontModel(uiName: 'font'),
          selectedSoundEvent: null,
        ),
      );

      final status = store.dispatchSync(RemoveSelectedSoundEvent());

      expect(status.isCompletedOk, isTrue);
      expect(store.state.selectedSoundEvent, isNull);
      expect(store.state.selectedFont, isNotNull);
    });
  });
}
