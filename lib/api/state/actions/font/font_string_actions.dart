import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/font/font_string_dto.dart';
import 'package:stelaris/api/model/font_model.dart';
import 'package:stelaris/api/paginated_result.dart';
import 'package:stelaris/api/state/app_state.dart';

/// Fetches additional characters for the selected font and updates the state.
/// Requires the id of the [FontModel] to fetch the characters for it.
class FontCharFetchAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    if (state.selectedFont == null) return null;
    final FontModel selected = state.selectedFont!;

    // If we already have items and more pages, treat this as load-more.
    final hasExisting = selected.chars.hasItems;
    final canLoadMore = selected.chars.hasNextPage;

    if (hasExisting && canLoadMore) {
      if (state.isLoadingMoreItems) return null;
      dispatchSync(_SetLoreCharModelLoad(true));
      try {
        final current = selected.chars;
        final nextPage = current.currentPage + 1;
        final size = 10;
        final next = await ApiService().fontApi.getChars(
          selected.id!,
          page: nextPage,
          size: size,
        );

        final merged = List<FontStringDTO>.of(current.items)
          ..addAll(next.items);
        final updated = selected.copyWith(
          chars: current.copyWith(
            items: merged,
            totalItems: next.totalItems != 0
                ? next.totalItems
                : current.totalItems,
            totalPages: next.totalPages != 0
                ? next.totalPages
                : current.totalPages,
            currentPage: next.currentPage != 0 ? next.currentPage : nextPage,
            pageSize: next.pageSize != 0 ? next.pageSize : size,
          ),
        );

        return state.copyWith(selectedFont: updated);
      } finally {
        dispatchSync(_SetLoreCharModelLoad(false));
      }
    } else {
      // Initial load (or refresh)
      final PaginatedResult<FontStringDTO> result = await ApiService().fontApi
          .getChars(
            selected.id!,
            page: 1,
            size: selected.chars.pageSize == 0 ? 10 : selected.chars.pageSize,
          );
      final FontModel updated = selected.copyWith(chars: result);
      return state.copyWith(selectedFont: updated);
    }
  }
}

class FontStringUpdateAction extends ReduxAction<AppState> {
  final FontStringDTO dto;

  FontStringUpdateAction(this.dto);

  @override
  Future<AppState?> reduce() async {
    if (state.selectedFont == null) return null;
    final FontModel selected = state.selectedFont!;
    final FontStringDTO savedModel = await ApiService().fontApi.updateFontEntry(
      selected.id!,
      dto,
    );
    final FontModel newModel = selected.copyWith();

    return state.copyWith(selectedFont: newModel);
  }
}

/// Internal action to manage the loading state for item pagination.
///
/// This private action controls the `isLoadingMoreItems` flag in the state,
/// preventing multiple simultaneous load-more requests. It's used internally
/// by InitItemAction during pagination operations.
class _SetLoreCharModelLoad extends ReduxAction<AppState> {
  final bool value;

  _SetLoreCharModelLoad(this.value);

  @override
  Future<AppState?> reduce() async {
    if (state.selectedFont == null) return null;

    final font = state.selectedFont!;
    final updatedStateFont = font.copyWith(isLoadingChars: value);
    return state.copyWith(selectedFont: updatedStateFont);
  }
}
