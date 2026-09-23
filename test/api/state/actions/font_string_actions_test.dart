import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/font/font_string_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/recording_http_client_adapter.dart';

void main() {
  group('FontCharFetchAction', () {
    test(
      'does not fetch more chars while the font is already loading them, '
      'even if an unrelated global loading flag is set',
      () async {
        const loadingFont = FontModel(
          uiName: 'font',
          isLoadingChars: true,
          chars: PaginatedResult(
            items: [FontStringDTO(line: 'a')],
            totalItems: 20,
            totalPages: 2,
            currentPage: 1,
            pageSize: 10,
          ),
        );

        final store = Store<AppState>(
          initialState: const AppState().copyWith(
            selectedFont: loadingFont,
            // Regression guard: this must NOT influence font-chars pagination.
            isLoadingMoreItems: true,
          ),
        );

        final status = await store.dispatchAndWait(FontCharFetchAction());

        expect(status.isCompletedOk, isTrue);
        // State is untouched: no API call was attempted, no dispatch happened.
        expect(store.state.selectedFont, same(loadingFont));
      },
    );
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
