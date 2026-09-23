import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/service/client/sound_client_api.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

void main() {
  group('InitSoundAction', () {
    test(
      'does nothing when all pages are already loaded, instead of '
      'resetting the list back to page 1 (regression)',
      () async {
        final loadedItems = List.generate(
          4,
          (i) => SoundEventModel(uiName: 'existing-$i', id: '$i'),
        );
        final store = Store<AppState>(
          initialState: const AppState().copyWith(
            soundEvents: PaginatedResult<SoundEventModel>(
              items: loadedItems,
              totalItems: 4,
              totalPages: 2,
              currentPage: 2,
              pageSize: 2,
            ),
          ),
        );
        final before = store.state;

        await store.dispatchAndWait(InitSoundAction());

        expect(identical(store.state, before), isTrue);
        expect(store.state.soundEvents.items, loadedItems);
      },
    );
  });

  group('RefreshSoundAction', () {
    test(
      'always refetches page 1 and replaces the list, even when more '
      'pages were already loaded',
      () async {
        final staleItems = List.generate(
          4,
          (i) => SoundEventModel(uiName: 'stale-$i', id: 'stale-$i'),
        );
        final store = Store<AppState>(
          initialState: const AppState().copyWith(
            soundEvents: PaginatedResult<SoundEventModel>(
              items: staleItems,
              totalItems: 4,
              totalPages: 2,
              currentPage: 2,
              pageSize: 2,
            ),
          ),
        );

        final fresh = SoundEventModel(uiName: 'fresh-0', id: 'fresh-0');
        (ApiService().soundApi as SoundClientApi)
            .apiClient
            .dio
            .httpClientAdapter = FakeHttpClientAdapter.json({
          'items': [fresh.toJson()],
          'totalItems': 1,
          'totalPages': 1,
          'currentPage': 1,
          'pageSize': 2,
        });

        await store.dispatchAndWait(RefreshSoundAction());

        expect(store.state.soundEvents.items.map((e) => e.id), ['fresh-0']);
        expect(store.state.soundEvents.currentPage, 1);
      },
    );
  });

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

  // The backend's update response never carries the files (they have their
  // own endpoints) — saving the form must not wipe them locally.
  group('SoundDatabaseUpdate relationships', () {
    test('keeps the loaded files in the selection, the list gets the saved '
        'state only', () async {
      const files = PaginatedResult<SoundFileSource>(
        items: [
          SoundFileSource(
            id: 's1',
            name: 'step',
            volume: 1,
            pitch: 1,
            attenuationDistance: 16,
            preload: false,
            type: 'file',
            weight: 1,
          ),
        ],
        totalItems: 1,
        totalPages: 1,
        currentPage: 1,
        pageSize: 10,
      );
      final saved = SoundEventModel(id: 'e1', uiName: 'Steps', files: files);
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedSoundEvent: saved.copyWith(uiName: 'Footsteps'),
          soundEvents: PaginatedResult<SoundEventModel>(
            items: [saved],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      (ApiService().soundApi as SoundClientApi).apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json({'id': 'e1', 'uiName': 'Footsteps'});

      await store.dispatchAndWait(SoundDatabaseUpdate());

      expect(store.state.selectedSoundEvent!.uiName, 'Footsteps');
      expect(store.state.selectedSoundEvent!.files, files);

      // Relationships only live in the selection; the list holds what the
      // server returns, like a fresh list fetch would.
      final listed = store.state.soundEvents.items.single;
      expect(listed.uiName, 'Footsteps');
      expect(listed.files.items, isEmpty);
    });
  });
}
