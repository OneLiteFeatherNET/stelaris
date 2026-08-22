import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

void main() {
  group('FontAddAction', () {
    test(
      'increments totalItems by one instead of falling back to the '
      'loaded-page count',
      () async {
        // Only one page (of several) is loaded locally, but the backend
        // knows the real total across all pages.
        final loadedPage = List.generate(
          2,
          (i) => FontModel(uiName: 'existing-$i', id: '$i'),
        );
        final store = Store<AppState>(
          initialState: const AppState().copyWith(
            fonts: PaginatedResult<FontModel>(
              items: loadedPage,
              totalItems: 20,
              totalPages: 10,
              currentPage: 1,
              pageSize: 2,
            ),
          ),
        );

        const added = FontModel(uiName: 'new-font', id: 'new-id');
        ApiService().fontApi.apiClient.dio.httpClientAdapter =
            FakeHttpClientAdapter.json(added.toJson());

        await store.dispatchAndWait(FontAddAction(added));

        expect(store.state.fonts.totalItems, 21);
        expect(store.state.fonts.items.last.id, 'new-id');
      },
    );
  });

  group('FontRemoveAction', () {
    test('decrements totalItems by one', () async {
      const existing = FontModel(uiName: 'to-remove', id: 'rm-id');
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          fonts: const PaginatedResult<FontModel>(
            items: [existing],
            totalItems: 20,
            totalPages: 10,
            currentPage: 1,
            pageSize: 2,
          ),
        ),
      );

      ApiService().fontApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(existing.toJson());

      await store.dispatchAndWait(FontRemoveAction(existing));

      expect(store.state.fonts.totalItems, 19);
      expect(store.state.fonts.items, isEmpty);
    });
  });
}
