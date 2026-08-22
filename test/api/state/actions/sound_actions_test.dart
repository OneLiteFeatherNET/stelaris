import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/service/client/sound_client_api.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

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

  group('SoundAddAction', () {
    test('increments totalItems by one', () async {
      final loadedPage = List.generate(
        2,
        (i) => SoundEventModel(uiName: 'existing-$i', id: '$i'),
      );
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          soundEvents: PaginatedResult<SoundEventModel>(
            items: loadedPage,
            totalItems: 20,
            totalPages: 10,
            currentPage: 1,
            pageSize: 2,
          ),
        ),
      );

      final added = SoundEventModel(uiName: 'new-sound', id: 'new-id');
      (ApiService().soundApi as SoundClientApi).apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(added.toJson());

      await store.dispatchAndWait(SoundAddAction(added));

      expect(store.state.soundEvents.totalItems, 21);
      expect(store.state.soundEvents.items.last.id, 'new-id');
    });
  });

  group('SoundRemoveAction', () {
    test('decrements totalItems by one', () async {
      final existing = SoundEventModel(uiName: 'to-remove', id: 'rm-id');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          soundEvents: PaginatedResult<SoundEventModel>(
            items: [existing],
            totalItems: 20,
            totalPages: 10,
            currentPage: 1,
            pageSize: 2,
          ),
        ),
      );

      (ApiService().soundApi as SoundClientApi).apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(existing.toJson());

      await store.dispatchAndWait(SoundRemoveAction(existing));

      expect(store.state.soundEvents.totalItems, 19);
      expect(store.state.soundEvents.items, isEmpty);
    });
  });
}
