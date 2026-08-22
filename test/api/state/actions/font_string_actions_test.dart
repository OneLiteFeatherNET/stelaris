import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/actions/font/font_string_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('FontCharFetchAction', () {
    test(
      'does not fetch more chars while the font is already loading them, '
      'even if an unrelated global loading flag is set',
      () async {
        final loadingFont = FontModel(
          uiName: 'font',
          isLoadingChars: true,
          chars: const PaginatedResult(
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
}
