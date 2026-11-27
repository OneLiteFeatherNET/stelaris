import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/paginated_loading.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';

/// Loads the chars of the selected font: the first page when none is loaded,
/// and the next page otherwise. The chars tab dispatches it when it opens.
class FontCharFetchAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    if (state.selectedFont == null) return null;
    final FontModel selected = state.selectedFont!;

    if (selected.chars.hasItems && selected.chars.hasNextPage) {
      await dispatchAndWait(FontCharLoadMoreAction());
      return null;
    }

    final PaginatedResult<FontStringDTO> result = await ApiService().fontApi
        .getChars(selected.id!, page: 1, size: selected.chars.requestSize);
    return state.copyWith(selectedFont: selected.copyWith(chars: result));
  }
}

/// Appends the next page of chars to the selected font, if there is one.
///
/// While it loads, `isWaiting(FontCharLoadMoreAction)` is true, and another
/// one dispatched meanwhile is dropped.
class FontCharLoadMoreAction extends ReduxAction<AppState> with NonReentrant {
  @override
  Future<AppState?> reduce() async {
    final FontModel? selected = state.selectedFont;
    if (selected == null) return null;

    final current = selected.chars;
    if (!current.hasItems || !current.hasNextPage) return null;

    final next = await ApiService().fontApi.getChars(
      selected.id!,
      page: current.currentPage + 1,
      size: current.requestSize,
    );

    // Another font was selected, or the chars of this one changed, while
    // the page loaded, so the page no longer continues them.
    final font = state.selectedFont;
    if (font == null ||
        font.id != selected.id ||
        !identical(font.chars, current)) {
      return null;
    }

    // Built on the current font, so form edits made while the page loaded
    // are kept.
    return state.copyWith(
      selectedFont: font.copyWith(chars: current.append(next)),
    );
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
