import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/service/client/sound_client_api.dart';
import 'package:stelaris/api/state/actions/sound/sound_file_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

/// Sets the selected sound event, as the form or a click on another sound
/// event would.
class _SelectSound extends ReduxAction<AppState> {
  _SelectSound(this.sound);

  final SoundEventModel sound;

  @override
  AppState reduce() => state.copyWith(selectedSoundEvent: sound);
}

SoundFileSource file(String id) => SoundFileSource(
  id: id,
  name: id,
  volume: 1,
  pitch: 1,
  attenuationDistance: 16,
  preload: false,
  type: 'file',
  weight: 1,
);

Map<String, Object?> json(String id, {String name = ''}) => {
  'id': id,
  'name': name.isEmpty ? id : name,
  'volume': 1.0,
  'pitch': 1.0,
  'attenuationDistance': 16,
  'preload': false,
  'type': 'file',
  'weight': 1,
};

void main() {
  final sound = SoundEventModel(
    id: 'sound-1',
    uiName: 'sound',
    files: PaginatedResult(
      items: [file('f1')],
      totalItems: 4,
      totalPages: 2,
      currentPage: 1,
      pageSize: 2,
    ),
  );
  final other = SoundEventModel(id: 'sound-2', uiName: 'other');

  Store<AppState> storeWith(SoundEventModel sound) =>
      Store<AppState>(initialState: AppState(selectedSoundEvent: sound));

  /// Answers with [json], after renaming the selection as the form would.
  void respondAfterRename(Store<AppState> store, Object json) {
    (ApiService().soundApi as SoundClientApi).apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter((options) {
          store.dispatchSync(
            _SelectSound(
              store.state.selectedSoundEvent!.copyWith(uiName: 'Renamed'),
            ),
          );
          return FakeHttpClientAdapter.response(json);
        });
  }

  /// Answers with [json], after selecting [other].
  void respondAfterSelectingOther(Store<AppState> store, Object json) {
    (ApiService().soundApi as SoundClientApi).apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter((options) {
          store.dispatchSync(_SelectSound(other));
          return FakeHttpClientAdapter.response(json);
        });
  }

  List<String?> fileIds(Store<AppState> store) =>
      store.state.selectedSoundEvent!.files.items.map((f) => f.id).toList();

  group('SoundFileLinkAction', () {
    test(
      'keeps form edits made while the file is linked (regression)',
      () async {
        final store = storeWith(sound);
        respondAfterRename(store, json('f2'));

        await store.dispatchAndWait(SoundFileLinkAction(file('f2')));

        expect(store.state.selectedSoundEvent!.uiName, 'Renamed');
        expect(fileIds(store), ['f1', 'f2']);
        expect(store.state.selectedSoundEvent!.files.totalItems, 5);
      },
    );

    test('leaves another selected sound event alone (regression)', () async {
      final store = storeWith(sound);
      respondAfterSelectingOther(store, json('f2'));

      await store.dispatchAndWait(SoundFileLinkAction(file('f2')));

      expect(store.state.selectedSoundEvent, other);
    });
  });

  group('SoundFileUpdateAction', () {
    test(
      'keeps form edits made while the file is saved (regression)',
      () async {
        final store = storeWith(sound);
        respondAfterRename(store, json('f1', name: 'changed'));

        await store.dispatchAndWait(SoundFileUpdateAction(file('f1')));

        expect(store.state.selectedSoundEvent!.uiName, 'Renamed');
        expect(
          store.state.selectedSoundEvent!.files.items.single.name,
          'changed',
        );
      },
    );

    test('leaves another selected sound event alone (regression)', () async {
      final store = storeWith(sound);
      respondAfterSelectingOther(store, json('f1', name: 'changed'));

      await store.dispatchAndWait(SoundFileUpdateAction(file('f1')));

      expect(store.state.selectedSoundEvent, other);
    });
  });

  group('SoundFileSourceDeleteAction', () {
    test(
      'keeps form edits made while the file is deleted (regression)',
      () async {
        final store = storeWith(sound);
        respondAfterRename(store, json('f1'));

        await store.dispatchAndWait(SoundFileSourceDeleteAction(file('f1')));

        expect(store.state.selectedSoundEvent!.uiName, 'Renamed');
        expect(fileIds(store), isEmpty);
        expect(store.state.selectedSoundEvent!.files.totalItems, 3);
      },
    );

    test('leaves another selected sound event alone (regression)', () async {
      final store = storeWith(sound);
      respondAfterSelectingOther(store, json('f1'));

      await store.dispatchAndWait(SoundFileSourceDeleteAction(file('f1')));

      expect(store.state.selectedSoundEvent, other);
    });
  });

  final nextPage = {
    'items': [json('f2')],
    'totalItems': 4,
    'totalPages': 2,
    'currentPage': 2,
    'pageSize': 2,
  };

  group('LoadMoreSoundFiles', () {
    LoadMoreSoundFiles loadMore() =>
        LoadMoreSoundFiles(pageToLoad: 2, pageSize: 2);

    test('appends the next files to the loaded ones', () async {
      final store = storeWith(sound);
      (ApiService().soundApi as SoundClientApi)
          .apiClient
          .dio
          .httpClientAdapter = FakeHttpClientAdapter.json(
        nextPage,
      );

      await store.dispatchAndWait(loadMore());

      expect(fileIds(store), ['f1', 'f2']);
      expect(store.state.selectedSoundEvent!.files.currentPage, 2);
      expect(store.state.selectedSoundEvent!.isLoading, isFalse);
    });

    test('keeps form edits made while the next files load '
        '(regression)', () async {
      final store = storeWith(sound);
      respondAfterRename(store, nextPage);

      await store.dispatchAndWait(loadMore());

      expect(store.state.selectedSoundEvent!.uiName, 'Renamed');
      expect(fileIds(store), ['f1', 'f2']);
      expect(store.state.selectedSoundEvent!.isLoading, isFalse);
    });

    test('drops the next files when another sound event is selected '
        'while they load (regression)', () async {
      final store = storeWith(sound);
      respondAfterSelectingOther(store, nextPage);

      await store.dispatchAndWait(loadMore());

      expect(store.state.selectedSoundEvent, other);
    });

    test('drops the next files when the loaded ones changed while they '
        'load', () async {
      final store = storeWith(sound);
      (ApiService().soundApi as SoundClientApi)
          .apiClient
          .dio
          .httpClientAdapter = FakeHttpClientAdapter((options) {
        store.dispatchSync(
          _SelectSound(
            store.state.selectedSoundEvent!.copyWith(
              files: PaginatedResult(
                items: [file('fresh')],
                totalItems: 1,
                totalPages: 1,
                currentPage: 1,
                pageSize: 2,
              ),
            ),
          ),
        );
        return FakeHttpClientAdapter.response(nextPage);
      });

      await store.dispatchAndWait(loadMore());

      expect(fileIds(store), ['fresh']);
    });
  });

  group('InitSoundFileAction', () {
    final empty = SoundEventModel(id: 'sound-1', uiName: 'sound');
    final firstPage = {
      'items': [json('f1')],
      'totalItems': 1,
      'totalPages': 1,
      'currentPage': 1,
      'pageSize': 20,
    };

    test('keeps form edits made while the files load (regression)', () async {
      final store = storeWith(empty);
      respondAfterRename(store, firstPage);

      await store.dispatchAndWait(InitSoundFileAction());

      expect(store.state.selectedSoundEvent!.uiName, 'Renamed');
      expect(fileIds(store), ['f1']);
    });

    test('drops the files when another sound event is selected while they '
        'load (regression)', () async {
      final store = storeWith(empty);
      respondAfterSelectingOther(store, firstPage);

      await store.dispatchAndWait(InitSoundFileAction());

      expect(store.state.selectedSoundEvent, other);
    });
  });
}
