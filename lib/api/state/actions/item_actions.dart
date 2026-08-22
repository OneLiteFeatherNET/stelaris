import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';

class SelectedItemAction extends ReduxAction<AppState> {
  final ItemModel model;

  SelectedItemAction(this.model);

  @override
  AppState reduce() {
    return state.copyWith(selectedItem: model);
  }
}

class RemoveSelectItemAction extends ReduxAction<AppState> {
  RemoveSelectItemAction();

  @override
  AppState? reduce() {
    if (state.selectedItem == null) return null;
    return state.copyWith(selectedItem: null);
  }
}

class UpdateItemAction extends ReduxAction<AppState> {
  final ItemModel newEntry;

  UpdateItemAction(this.newEntry);

  @override
  Future<AppState?> reduce() async {
    return state.copyWith(selectedItem: newEntry);
  }
}

class InitItemAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    // If we already have items and more pages, treat this as load-more.
    final hasExisting = state.items.items.isNotEmpty;
    final canLoadMore = state.items.hasNextPage;

    if (hasExisting && canLoadMore) {
      if (state.isLoadingMoreItems) return null;
      dispatchSync(_SetLoadMoreItemModels(true));
      try {
        final current = state.items;
        final nextPage = current.currentPage + 1;
        final size = 10;
        final next = await ApiService().itemApi.getPage(
          page: nextPage,
          size: size,
        );

        final merged = List<ItemModel>.of(current.items)..addAll(next.items);
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
        return state.copyWith(items: updated);
      } finally {
        dispatchSync(_SetLoadMoreItemModels(false));
      }
    } else {
      // Initial load (or refresh)
      final PaginatedResult<ItemModel> result = await ApiService().itemApi
          .getPage(
            page: 1,
            size: state.items.pageSize == 0 ? 10 : state.items.pageSize,
          );
      return state.copyWith(items: result);
    }
  }
}

/// Internal action to manage the loading state for item pagination.
///
/// This private action controls the `isLoadingMoreItems` flag in the state,
/// preventing multiple simultaneous load-more requests. It's used internally
/// by InitItemAction during pagination operations.
class _SetLoadMoreItemModels extends ReduxAction<AppState> {
  final bool value;
  _SetLoadMoreItemModels(this.value);
  @override
  AppState reduce() => state.copyWith(isLoadingMoreItems: value);
}

class ItemAddAction extends ReduxAction<AppState> {
  final ItemModel _model;

  ItemAddAction(this._model);

  @override
  Future<AppState?> reduce() async {
    final ItemModel added = await ApiService().itemApi.add(_model);
    final List<ItemModel> items = List.of(state.items.items, growable: true)
      ..add(added);
    return _updateItemInState(
      state,
      items,
      added,
      totalItems: state.items.totalItems + 1,
    );
  }
}

class ItemRemoveAction extends ReduxAction<AppState> {
  final ItemModel model;

  ItemRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final ItemModel removedEntry = await ApiService().itemApi.remove(model);
    final List<ItemModel> items = List.of(state.items.items, growable: true)
      ..removeWhere((element) => element.id == removedEntry.id);
    return _updateItemInState(state, items, null);
  }
}

class ItemDatabaseUpdate extends ReduxAction<AppState> {
  ItemDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;
    final ItemModel selected = state.selectedItem!;
    final ItemModel dbModel = await ApiService().itemApi.update(selected);
    return updateSingleItemInState(state, dbModel);
  }
}

class ItemFlagFetchAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;
    final ItemModel selected = state.selectedItem!;
    /*final ItemFlagModel dbModel = await ApiService().itemApi.getFlags(
      selected.id!,
    );*/
    //final ItemModel updatedItem = selected.copyWith(flags: dbModel.flags);
    return state.copyWith(selectedItem: selected);
  }
}

AppState updateSingleItemInState(AppState state, ItemModel updatedItem) {
  final List<ItemModel> itemList = List.of(state.items.items);
  final int index = itemList.indexWhere((item) => item.id == updatedItem.id);
  if (index != -1) {
    itemList[index] = updatedItem;
  }
  return _updateItemInState(state, itemList, updatedItem);
}

AppState _updateItemInState(
  AppState state,
  List<ItemModel> newItems,
  ItemModel? selectedItem, {
  int? totalItems,
}) {
  final updated = state.items.copyWith(
    items: newItems,
    totalItems: totalItems ?? state.items.totalItems,
    totalPages: state.items.totalPages,
    currentPage: state.items.currentPage,
    pageSize: state.items.pageSize,
  );
  return state.copyWith(items: updated, selectedItem: selectedItem);
}
