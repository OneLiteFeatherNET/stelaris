import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';

class SelectFontAction extends ReduxAction<AppState> {
  final FontModel model;

  SelectFontAction(this.model);

  @override
  AppState reduce() => state
      .copyWith(selectedFont: model)
      .clearUnsavedChanges(NavigationEntry.font);
}

class RemoveSelectedFont extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    if (state.selectedFont == null) return null;
    return state
        .copyWith(selectedFont: null)
        .clearUnsavedChanges(NavigationEntry.font);
  }
}

/// Always refetches page 1 and replaces the current list, regardless of
/// how many pages were already loaded — used by the grid's manual refresh
/// button, as opposed to [InitFontAction] which only ever loads the next
/// page or the very first page.
class RefreshFontAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final PaginatedResult<FontModel> result = await ApiService().fontApi
        .getPage(
          page: 1,
          size: state.fonts.pageSize == 0 ? 10 : state.fonts.pageSize,
          projectId: state.selectedProject?.id,
        );
    return state.copyWith(fonts: result);
  }
}

class InitFontAction extends ReduxAction<AppState> {
  InitFontAction();

  @override
  Future<AppState?> reduce() async {
    // If we already have items and more pages, treat this as load-more.
    final hasExisting = state.fonts.items.isNotEmpty;
    final canLoadMore = state.fonts.hasNextPage;

    if (hasExisting && !canLoadMore) return null;

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
          projectId: state.selectedProject?.id,
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
            projectId: state.selectedProject?.id,
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
    final toRemove = model.projectId == null && state.selectedProject != null
        ? model.copyWith(projectId: state.selectedProject!.id)
        : model;
    final FontModel removedEntry = await ApiService().fontApi.remove(toRemove);
    final List<FontModel> items = List.of(state.fonts.items, growable: true)
      ..removeWhere((element) => element.id == removedEntry.id);
    // The selection stays: when deleting from the detail page, that page is
    // still mounted during its exit transition and reads it. The page's
    // onDispose clears it.
    return _updateFontInState(
      state,
      items,
      state.selectedFont,
      totalItems: state.fonts.totalItems - 1,
    );
  }
}

class FontAddAction extends ReduxAction<AppState> with NonReentrant {
  final FontModel _model;

  FontAddAction(this._model);

  @override
  Future<AppState?> reduce() async {
    final toAdd = _model.projectId == null && state.selectedProject != null
        ? _model.copyWith(projectId: state.selectedProject!.id)
        : _model;
    final FontModel added = await ApiService().fontApi.add(toAdd);
    final List<FontModel> items = List.of(state.fonts.items, growable: true)
      ..add(added);
    return _updateFontInState(
      state,
      items,
      added,
      totalItems: state.fonts.totalItems + 1,
    );
  }
}

class UpdateFontAction extends ReduxAction<AppState> {
  final FontModel newEntry;

  UpdateFontAction(this.newEntry);

  @override
  Future<AppState?> reduce() async => state.copyWith(
    selectedFont: newEntry,
    unsavedChanges: NavigationEntry.font,
  );
}

class FontDatabaseUpdate extends ReduxAction<AppState> with Throttle {
  FontDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedFont == null) return null;
    final FontModel selected =
        state.selectedFont!.projectId == null && state.selectedProject != null
            ? state.selectedFont!.copyWith(projectId: state.selectedProject!.id)
            : state.selectedFont!;
    final FontModel response = await ApiService().fontApi.update(selected);
    // The update response only carries the form fields — the backend never
    // returns relationships, they have their own endpoints. The list gets
    // the response as is (like a fresh list fetch); the selection keeps the
    // loaded relationships, read after the await so changes made meanwhile
    // aren't lost.
    final dbModel = response.copyWith(
      chars: (state.selectedFont ?? selected).chars,
    );

    final List<FontModel> updatedList = List.of(
      state.fonts.items,
      growable: true,
    );
    final int index = updatedList.indexWhere(
      (element) => element.id == selected.id,
    );

    if (index != -1) {
      updatedList[index] = response;
    }

    return _updateFontInState(
      state,
      updatedList,
      dbModel,
    ).clearUnsavedChanges(NavigationEntry.font);
  }
}

class _SetLoadMoreFontModels extends ReduxAction<AppState> {
  final bool value;

  _SetLoadMoreFontModels(this.value);

  @override
  AppState reduce() => state.copyWith(isLoadingMoreFonts: value);
}

AppState _updateFontInState(
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
