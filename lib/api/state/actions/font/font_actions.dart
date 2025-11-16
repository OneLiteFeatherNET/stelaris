import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/font_model.dart';
import 'package:stelaris/api/paginated_result.dart';
import 'package:stelaris/api/state/app_state.dart';

class SelectFontAction extends ReduxAction<AppState> {
  final FontModel model;

  SelectFontAction(this.model);

  @override
  AppState reduce() => state.copyWith(selectedFont: model);
}

class RemoveSelectedFont extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    if (state.selectedFont == null) return null;
    return state.copyWith(selectedFont: null);
  }
}

class InitFontAction extends ReduxAction<AppState> {
  InitFontAction();

  @override
  Future<AppState?> reduce() async {
    // If we already have items and more pages, treat this as load-more.
    final hasExisting = state.fonts.items.isNotEmpty;
    final canLoadMore = state.fonts.hasNextPage;

    if (hasExisting && canLoadMore) {
      if (state.isLoadingMoreFonts) return null;
      dispatchSync(_SetLoadMoreFontModels(true));
      try {
        final current = state.fonts;
        final nextPage = current.currentPage + 1;
        final size = 10;
        final next = await ApiService().fontApi.getPage(
          page: nextPage,
          size: size,
        );

        final merged = List<FontModel>.of(current.items)..addAll(next.items);
        final updated = current.copyWith(
          items: merged,
          totalItems: next.totalItems != 0
              ? next.totalItems
              : current.totalItems,
          totalPages: next.totalPages != 0
              ? next.totalPages
              : current.totalPages,
          currentPage: next.currentPage != 0 ? next.currentPage : nextPage,
          pageSize: next.pageSize != 0 ? next.pageSize : size,
        );
        return state.copyWith(fonts: updated);
      } finally {
        dispatchSync(_SetLoadMoreFontModels(false));
      }
    } else {
      // Initial load (or refresh)
      final PaginatedResult<FontModel> result = await ApiService().fontApi
          .getPage(
            page: 1,
            size: state.fonts.pageSize == 0 ? 10 : state.fonts.pageSize,
          );
      return state.copyWith(fonts: result);
    }
  }
}

class FontRemoveAction extends ReduxAction<AppState> {
  final FontModel model;

  FontRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final FontModel removedEntry = await ApiService().fontApi.remove(model);
    final List<FontModel> items = List.of(state.fonts.items, growable: true)
      ..removeWhere((element) => element.id == removedEntry.id);
    return _updateItemInState(state, items, null);
  }
}

class FontAddAction extends ReduxAction<AppState> {
  final FontModel _model;

  FontAddAction(this._model);

  @override
  Future<AppState?> reduce() async {
    final FontModel added = await ApiService().fontApi.add(_model);
    final List<FontModel> items = List.of(state.fonts.items, growable: true)
      ..add(added);
    return _updateItemInState(state, items, added, totalItems: items.length);
  }
}

class UpdateFontAction extends ReduxAction<AppState> {
  final FontModel newEntry;

  UpdateFontAction(this.newEntry);

  @override
  Future<AppState?> reduce() async => state.copyWith(selectedFont: newEntry);
}

class FontDatabaseUpdate extends ReduxAction<AppState> {
  FontDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedFont == null) return null;
    final FontModel selected = state.selectedFont!;
    final FontModel dbModel = await ApiService().fontApi.update(selected);

    final List<FontModel> updatedList = List.of(
      state.fonts.items,
      growable: true,
    );
    final int index = updatedList.indexWhere(
      (element) => element.id == selected.id,
    );

    if (index != -1) {
      updatedList[index] = dbModel;
    }

    return _updateItemInState(state, updatedList, dbModel);
  }
}

class _SetLoadMoreFontModels extends ReduxAction<AppState> {
  final bool value;

  _SetLoadMoreFontModels(this.value);

  @override
  AppState reduce() => state.copyWith(isLoadingMoreFonts: value);
}

AppState _updateItemInState(
  AppState state,
  List<FontModel> newItems,
  FontModel? selectedItem, {
  int? totalItems,
}) {
  final updated = state.fonts.copyWith(
    items: newItems,
    totalItems: totalItems ?? state.fonts.totalItems,
    totalPages: state.fonts.totalPages,
    currentPage: state.fonts.currentPage,
    pageSize: state.fonts.pageSize,
  );
  return state.copyWith(fonts: updated, selectedFont: selectedItem);
}
