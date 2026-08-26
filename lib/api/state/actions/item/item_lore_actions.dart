import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';

/// Action for the initial fetch of lore (page 1).
class ItemLoreFetchAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final selectedItem = state.selectedItem;
    if (selectedItem == null) return null;

    final PaginatedResult<ItemLoreDto> result = await ApiService().itemApi
        .getLore(
          selectedItem.id!,
          page: selectedItem.lore.currentPage,
          size: selectedItem.lore.pageSize == 0
              ? 10
              : selectedItem.lore.pageSize,
        );

    final updatedItem = selectedItem.copyWith(lore: result);

    // Updated: Keep list and selectedItem in sync
    return _updateItemAndList(state, updatedItem);
  }
}

/// Action to fetch the next page of lore for pagination.
class ItemLoreLoadNextPageAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final selectedItem = state.selectedItem;
    if (selectedItem == null) return null;

    final lore = selectedItem.lore;
    final isLoading = selectedItem.isLoadingMoreLoreLines;

    // Guards: Exit if already loading, or if there are no items, or no more pages.
    if (isLoading || !lore.hasItems || !lore.hasNextPage) {
      return null;
    }

    dispatch(_SetIsLoadingLore(true));

    try {
      final nextPage = lore.currentPage + 1;

      final nextResult = await ApiService().itemApi.getLore(
        selectedItem.id!,
        page: nextPage,
        size: lore.pageSize,
      );

      final mergedItems = [...lore.items, ...nextResult.items];

      final updatedLore = lore.copyWith(
        items: mergedItems,
        totalItems: nextResult.totalItems,
        totalPages: nextResult.totalPages,
        currentPage: nextResult.currentPage,
      );

      final updatedItem = selectedItem.copyWith(lore: updatedLore);

      // Updated: Keep list and selectedItem in sync
      return _updateItemAndList(state, updatedItem);
    } finally {
      dispatch(_SetIsLoadingLore(false));
    }
  }
}

class ItemLoreAddAction extends ReduxAction<AppState> {
  ItemLoreAddAction(this.itemLoreDto);

  final ItemLoreDto itemLoreDto;

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;

    final itemModel = state.selectedItem!;

    final addedLore = await ApiService().itemApi.addLore(
      itemModel.id!,
      itemLoreDto,
    );

    final loreLines = itemModel.lore;

    final updatedLines = loreLines.copyWith(
      items: [...loreLines.items, addedLore],
      totalItems: loreLines.totalItems + 1,
    );

    final updatedModel = itemModel.copyWith(lore: updatedLines);

    return _updateItemAndList(state, updatedModel);
  }
}

class ItemLoreDeleteAction extends ReduxAction<AppState> {
  ItemLoreDeleteAction(this.itemLoreDto);

  final ItemLoreDto itemLoreDto;

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null || itemLoreDto.id == null) return null;

    final itemModel = state.selectedItem!;

    await ApiService().itemApi.deleteLore(itemModel.id!, itemLoreDto);

    final loreLines = itemModel.lore;

    final updatedLines = loreLines.copyWith(
      items: loreLines.items.where((l) => l.id != itemLoreDto.id).toList(),
      totalItems: loreLines.totalItems - 1,
    );

    final updatedModel = itemModel.copyWith(lore: updatedLines);

    return _updateItemAndList(state, updatedModel);
  }
}

class ItemLoreUpdateAction extends ReduxAction<AppState> {
  ItemLoreUpdateAction(this.dto);

  final ItemLoreDto dto;

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;

    final itemModel = state.selectedItem!;

    final updatedLore = await ApiService().itemApi.updateLore(
      itemModel.id!,
      dto,
    );

    final loreLines = itemModel.lore;

    final updatedLines = loreLines.copyWith(
      items: loreLines.items
          .map((l) => l.id == updatedLore.id ? updatedLore : l)
          .toList(),
    );

    final updatedModel = itemModel.copyWith(lore: updatedLines);

    return _updateItemAndList(state, updatedModel);
  }
}

class ItemLoreReorderAction extends ReduxAction<AppState> {
  ItemLoreReorderAction({
    required this.oldIndex,
    required this.newIndex,
  });

  final int oldIndex;
  final int newIndex;

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null || state.selectedItem!.id == null) {
      return null;
    }

    final itemModel = state.selectedItem!;
    final loreLines = itemModel.lore;

    if (oldIndex < 0 ||
        oldIndex >= loreLines.items.length ||
        newIndex < 0 ||
        newIndex >= loreLines.items.length ||
        oldIndex == newIndex) {
      return null;
    }

    final entry = loreLines.items[oldIndex];
    if (entry.id == null) return null;

    final updatedItems = List<ItemLoreDto>.from(loreLines.items);
    final movedItem = updatedItems.removeAt(oldIndex);
    updatedItems.insert(newIndex, movedItem);

    final reindexedItems = [
      for (var i = 0; i < updatedItems.length; i++)
        updatedItems[i].copyWith(orderIndex: i),
    ];

    await ApiService().itemApi.reorderLore(
      itemModel.id!,
      entryId: entry.id!,
      newIndex: newIndex,
    );

    final updatedLore = loreLines.copyWith(items: reindexedItems);
    final updatedModel = itemModel.copyWith(lore: updatedLore);

    return _updateItemAndList(state, updatedModel);
  }
}


class _SetIsLoadingLore extends ReduxAction<AppState> {
  final bool isLoading;

  _SetIsLoadingLore(this.isLoading);

  @override
  AppState reduce() {
    final currentItem = state.selectedItem;
    if (currentItem == null) return state;

    final updatedItem = currentItem.copyWith(isLoadingMoreLoreLines: isLoading);

    return state.copyWith(selectedItem: updatedItem);
  }
}

/// Updates the selected item and synchronizes it with the global item list.
///
/// This helper ensures that when an item is modified, both the currently
/// selected item and the shared list remain consistent. It replaces the item
/// in the list with its updated version and updates the `selectedItem` field.
///
/// Returns a new state with the updated list and selected item.
AppState _updateItemAndList(AppState state, ItemModel updatedItem) {
  final list = List<ItemModel>.from(state.items.items);
  final idx = list.indexWhere((i) => i.id == updatedItem.id);

  if (idx != -1) list[idx] = updatedItem;

  final updatedList = state.items.copyWith(items: list);

  return state.copyWith(items: updatedList, selectedItem: updatedItem);
}
