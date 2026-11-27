import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/font/font_string_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/recording_http_client_adapter.dart';

/// Sets the selected font, as the form or a click on another font would.
class _SelectFont extends ReduxAction<AppState> {
  _SelectFont(this.font);

  final FontModel font;

  @override
  AppState reduce() => state.copyWith(selectedFont: font);
}

void main() {
  group('FontCharFetchAction', () {
    const font = FontModel(
      id: 'font-1',
      uiName: 'font',
      chars: PaginatedResult(
        items: [FontStringDTO(id: 'c1', line: 'a')],
        totalItems: 4,
        totalPages: 2,
        currentPage: 1,
        pageSize: 2,
      ),
    );
    const nextPage = {
      'items': [
        {'id': 'c2', 'line': 'b'},
      ],
      'totalItems': 4,
      'totalPages': 2,
      'currentPage': 2,
      'pageSize': 2,
    };

    test('appends the next chars to the loaded ones (regression)', () async {
      final store = Store<AppState>(
        initialState: const AppState().copyWith(selectedFont: font),
      );
      ApiService().fontApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(nextPage);

      await store.dispatchAndWait(FontCharFetchAction());

      expect(store.state.selectedFont!.chars.items.map((c) => c.id), [
        'c1',
        'c2',
      ]);
    });

    test('loads the next chars only once when asked twice in a row '
        '(regression)', () async {
      final store = Store<AppState>(
        initialState: const AppState().copyWith(selectedFont: font),
      );
      var requests = 0;
      ApiService().fontApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            requests++;
            return FakeHttpClientAdapter.response(nextPage);
          });

      await Future.wait([
        store.dispatchAndWait(FontCharLoadMoreAction()),
        store.dispatchAndWait(FontCharFetchAction()),
      ]);

      expect(requests, 1);
      expect(store.state.selectedFont!.chars.items.map((c) => c.id), [
        'c1',
        'c2',
      ]);
    });

    test('counts as waiting while the next chars load', () async {
      final store = Store<AppState>(
        initialState: const AppState().copyWith(selectedFont: font),
      );
      bool? waitingDuringRequest;
      ApiService().fontApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            waitingDuringRequest = store.isWaiting(FontCharLoadMoreAction);
            return FakeHttpClientAdapter.response(nextPage);
          });

      await store.dispatchAndWait(FontCharFetchAction());

      expect(waitingDuringRequest, isTrue);
      expect(store.isWaiting(FontCharLoadMoreAction), isFalse);
    });

    test('loads the next chars in the size of the loaded pages', () async {
      final store = Store<AppState>(
        initialState: const AppState().copyWith(selectedFont: font),
      );
      String? size;
      ApiService().fontApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            size = options.uri.queryParameters['size'];
            return FakeHttpClientAdapter.response(nextPage);
          });

      await store.dispatchAndWait(FontCharFetchAction());

      expect(size, '2');
    });

    test('keeps form edits made while the next chars load', () async {
      final store = Store<AppState>(
        initialState: const AppState().copyWith(selectedFont: font),
      );
      ApiService().fontApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            store.dispatchSync(_SelectFont(font.copyWith(uiName: 'Renamed')));
            return FakeHttpClientAdapter.response(nextPage);
          });

      await store.dispatchAndWait(FontCharFetchAction());

      expect(store.state.selectedFont!.uiName, 'Renamed');
      expect(store.state.selectedFont!.chars.items.map((c) => c.id), [
        'c1',
        'c2',
      ]);
    });

    test('drops the next chars when another font is selected while they '
        'load', () async {
      const other = FontModel(id: 'font-2', uiName: 'other');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(selectedFont: font),
      );
      ApiService().fontApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            store.dispatchSync(_SelectFont(other));
            return FakeHttpClientAdapter.response(nextPage);
          });

      await store.dispatchAndWait(FontCharFetchAction());

      expect(store.state.selectedFont, other);
    });
  });

  group('unsaved form edits', () {
    test('deleting a char leaves the list entry untouched',
        () async {
      const char = FontStringDTO(id: 'c1', line: 'a');
      const saved = FontModel(
        id: 'font-1',
        uiName: 'Default',
        chars: PaginatedResult<FontStringDTO>(
          items: [char],
          totalItems: 1,
          totalPages: 1,
          currentPage: 1,
          pageSize: 10,
        ),
      );

      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          // The form renamed the font, but it hasn't been saved yet.
          selectedFont: saved.copyWith(uiName: 'Renamed'),
          fonts: const PaginatedResult<FontModel>(
            items: [saved],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      ApiService().fontApi.apiClient.dio.httpClientAdapter =
          RecordingHttpClientAdapter({'id': 'c1', 'line': 'a'});

      await store.dispatchAndWait(FontStringDelete('font-1', char));

      // Neither the unsaved rename nor the chars (which only live in the
      // selection) reach the list.
      expect(store.state.fonts.items.single, saved);
      expect(store.state.selectedFont!.uiName, 'Renamed');
      expect(store.state.selectedFont!.chars.items, isEmpty);
    });
  });
}
