import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/service/client/sound_client_api.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/list_actions.dart';

void main() {
  listActionTests<SoundEventModel>(
    model: (id, {projectId}) =>
        SoundEventModel(uiName: id, id: id, projectId: projectId),
    listOf: (state) => state.soundEvents,
    withList: (state, list) => state.copyWith(soundEvents: list),
    init: InitSoundAction.new,
    refresh: RefreshSoundAction.new,
    add: SoundAddAction.new,
    remove: SoundRemoveAction.new,
    copy: SoundCopyAction.new,
  );

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

  group('SoundNotesUpdateAction', () {
    test('replaces the list entry and only patches the notes into a '
        'selection of the same sound event', () async {
      final listed = SoundEventModel(id: 'sound-1', uiName: 'Footsteps');
      // The selection carries an unsaved rename that must survive.
      final selected = listed.copyWith(uiName: 'Renamed', comment: 'Old');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedSoundEvent: selected,
          soundEvents: PaginatedResult<SoundEventModel>(
            items: [listed],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      (ApiService().soundApi as SoundClientApi)
          .apiClient
          .dio
          .httpClientAdapter = FakeHttpClientAdapter.json({
        'id': 'sound-1',
        'uiName': 'Footsteps',
        'comment': 'Boss room',
      });

      await store.dispatchAndWait(SoundNotesUpdateAction(listed, 'Boss room'));

      expect(store.state.soundEvents.items.single.comment, 'Boss room');
      expect(store.state.selectedSoundEvent!.comment, 'Boss room');
      expect(store.state.selectedSoundEvent!.uiName, 'Renamed');
    });

    test('leaves a selection of another sound event alone', () async {
      final listed = SoundEventModel(id: 'sound-1', uiName: 'Footsteps');
      final other = SoundEventModel(
        id: 'sound-2',
        uiName: 'Other',
        comment: 'Old',
      );
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedSoundEvent: other,
          soundEvents: PaginatedResult<SoundEventModel>(
            items: [listed, other],
            totalItems: 2,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      (ApiService().soundApi as SoundClientApi)
          .apiClient
          .dio
          .httpClientAdapter = FakeHttpClientAdapter.json({
        'id': 'sound-1',
        'uiName': 'Footsteps',
        'comment': 'Boss room',
      });

      await store.dispatchAndWait(SoundNotesUpdateAction(listed, 'Boss room'));

      expect(store.state.selectedSoundEvent, other);
    });
  });
}
