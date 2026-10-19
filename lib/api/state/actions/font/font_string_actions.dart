import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/paginated_loading.dart';
import 'package:stelaris_models/stelaris_models.dart';
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
      if (selected.isLoadingChars) return null;
      dispatchSync(_SetLoreCharModelLoad(true));
      try {
        final current = selected.chars;
        final nextPage = current.currentPage + 1;
        final size = current.requestSize;
        final next = await ApiService().fontApi.getChars(
          selected.id!,
          page: nextPage,
          size: size,
        );

        // Another font was selected, or the chars of this one changed, while
        // the page loaded, so the page no longer continues them.
        final font = state.selectedFont;
        if (font == null ||
            font.id != selected.id ||
            !identical(font.chars, current)) {
          return null;
        }

        final merged = List<FontStringDTO>.of(current.items)
          ..addAll(next.items);
        // Built on the current font, so form edits made while the page
        // loaded are kept.
        final updated = font.copyWith(
          isLoadingChars: false,
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
            size: selected.chars.requestSize,
          );
      final FontModel updated = selected.copyWith(chars: result);
      return state.copyWith(selectedFont: updated);
    }
  }
}

class FontStringAddAction extends ReduxAction<AppState> {
  final FontStringDTO dto;

  FontStringAddAction(this.dto);

  @override
  Future<AppState?> reduce() async {
    if (state.selectedFont == null) return null;
    final selected = state.selectedFont!;

    final api = ApiService().fontApi;
    final added = await api.addFontEntry(selected.id!, dto);

    final updatedChars = selected.chars.copyWith(
      totalItems: selected.chars.totalItems + 1,
      items: [...selected.chars.items, added],
    );

    final updated = selected.copyWith(chars: updatedChars);

    return state.copyWith(selectedFont: updated);
  }
}

class FontStringEditAction extends ReduxAction<AppState> {
  final FontStringDTO dto;

  FontStringEditAction(this.dto);

  @override
  Future<AppState?> reduce() async {
    if (state.selectedFont == null) return null;
    final selected = state.selectedFont!;

    final savedModel = await ApiService().fontApi.updateFontEntry(
      selected.id!,
      dto,
    );

    final updatedItems = state.selectedFont!.chars.items.map((char) {
      return char.id == savedModel.id ? savedModel : char;
    }).toList();

    final newSelectedFont = selected.copyWith(
      chars: selected.chars.copyWith(items: updatedItems),
    );

    return state.copyWith(selectedFont: newSelectedFont);
  }
}

class FontStringDelete extends ReduxAction<AppState> {
  final String id;
  final FontStringDTO dto;

  FontStringDelete(this.id, this.dto);

  @override
  Future<AppState?> reduce() async {
    if (state.selectedFont == null) return null;
    final selected = state.selectedFont!;

    final removed = await ApiService().fontApi.deleteFontEntry(id, dto);

    final chars = selected.chars;

    // CLONE the list before mutation
    final updatedItems = List<FontStringDTO>.from(chars.items)
      ..removeWhere((element) => element.id == removed.id);

    final updated = selected.copyWith(
      chars: chars.copyWith(
        totalItems: chars.totalItems - 1,
        items: updatedItems,
      ),
    );

    return state.copyWith(selectedFont: updated);
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
  AppState? reduce() {
    if (state.selectedFont == null) return null;

    final font = state.selectedFont!;
    final updatedStateFont = font.copyWith(isLoadingChars: value);
    return state.copyWith(selectedFont: updatedStateFont);
  }
}
