import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/item/item_lore_dto.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/paginated_result.dart';
import 'package:stelaris/api/state/app_state.dart';

/// An action that loads lore lines for the currently selected item.
///
/// This action supports two loading modes:
///
/// * **Load more** – If the item already has lore entries and more pages are
///   available, it fetches the next page and merges the new results into the
///   existing list.
///
/// * **Initial fetch** – If no lore has been loaded yet (or a refresh is needed),
///   it loads the first page.
///
/// While additional pages are loading, the action sets a temporary loading
/// flag in the state to avoid triggering multiple parallel requests.
///
/// If no item is selected, the action does nothing.
class ItemLoreFetchAction extends ReduxAction<AppState> {
  ItemLoreFetchAction();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;

    final ItemModel itemModel = state.selectedItem!;

    final hasExisting = itemModel.lore.hasItems;
    final canLoadMore = itemModel.lore.hasNextPage;

    if (hasExisting && canLoadMore) {
      if (state.isLoadingMoreItems) return null;
      dispatchSync(_SetMoreLoreLoad(true));
      try {
        final current = itemModel.lore;
        final nextPage = current.currentPage + 1;
        final size = 10;
        final next = await ApiService().itemApi.getLore(
          itemModel.id!,
          page: nextPage,
          size: size,
        );

        final merged = List<ItemLoreDto>.of(current.items)..addAll(next.items);
        final updated = itemModel.copyWith(
          lore: current.copyWith(
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

        return state.copyWith(selectedItem: updated);
      } finally {
        dispatchSync(_SetMoreLoreLoad(false));
      }
    } else {
      // Initial load (or refresh)
      final PaginatedResult<ItemLoreDto> result = await ApiService().itemApi
          .getLore(
            itemModel.id!,
            page: 1,
            size: itemModel.lore.pageSize == 0 ? 10 : itemModel.lore.pageSize,
          );
      final ItemModel updated = itemModel.copyWith(lore: result);
      return state.copyWith(selectedItem: updated);
    }
  }
}

/// An action that adds a new lore line to the currently selected item.
///
/// This action sends the given [ItemLoreDto] to the backend, receives the
/// newly created lore entry, and updates the selected item's lore list in
/// the application state.
///
/// If no item is currently selected, the action does nothing.
///
/// The updated item is written back into the state so the UI can reflect the
/// change immediately.
class ItemLoreAddAction extends ReduxAction<AppState> {
  ItemLoreAddAction(this.itemLoreDto);

  final ItemLoreDto itemLoreDto;

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;

    final ItemModel itemModel = state.selectedItem!;

    final ItemLoreDto addedLore = await ApiService().itemApi.addLore(
      itemModel.id!,
      itemLoreDto,
    );

    final PaginatedResult<ItemLoreDto> loreLines = itemModel.lore;
    final PaginatedResult<ItemLoreDto> updatedLines = loreLines.copyWith(
      items: [...loreLines.items, addedLore],
      totalItems: loreLines.totalItems + 1,
    );

    final ItemModel updatedModel = itemModel.copyWith(lore: updatedLines);
    return state.copyWith(selectedItem: updatedModel);
  }
}

/// An action that removes a lore line from the currently selected item.
///
/// This action calls the backend to delete the given [ItemLoreDto] and then
/// updates the selected item's lore list by removing the deleted entry from
/// the local state.
///
/// If no item is selected, the action does nothing.
///
/// Once the lore entry is removed, the updated item is written back into the
/// state so the UI immediately reflects the change.
class ItemLoreDeleteAction extends ReduxAction<AppState> {
  ItemLoreDeleteAction(this.itemLoreDto);

  final ItemLoreDto itemLoreDto;

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;

    final ItemModel itemModel = state.selectedItem!;

    final ItemLoreDto deletedLore = await ApiService().itemApi.deleteLore(
      itemModel.id!,
      itemLoreDto,
    );

    final PaginatedResult<ItemLoreDto> loreLines = itemModel.lore;
    final PaginatedResult<ItemLoreDto> updatedLines = loreLines.copyWith(
      items: loreLines.items.where((l) => l.id != deletedLore.id).toList(),
      totalItems: loreLines.totalItems - 1,
    );

    final ItemModel updatedModel = itemModel.copyWith(lore: updatedLines);
    return state.copyWith(selectedItem: updatedModel);
  }
}

/// Internal action to manage the loading state for item pagination.
///
/// This private action controls the `isLoadingMoreItems` flag in the state,
/// preventing multiple simultaneous load-more requests. It's used internally
/// by InitItemAction during pagination operations.
class _SetMoreLoreLoad extends ReduxAction<AppState> {
  final bool value;

  _SetMoreLoreLoad(this.value);

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;

    final item = state.selectedItem!;
    final updatedItem = item.copyWith(isLoadingMoreLoreLines: value);
    return state.copyWith(selectedItem: updatedItem);
  }
}
