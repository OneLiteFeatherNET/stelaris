import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/item/item_lore_dto.dart';
import 'package:stelaris/api/paginated_result.dart';
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
      size: selectedItem.lore.pageSize == 0 ? 10 : selectedItem.lore.pageSize,
    );
    final updatedItem = selectedItem.copyWith(lore: result);
    return state.copyWith(selectedItem: updatedItem);
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

      debugPrint("Ipdate ${updatedLore.items.length}");
      return state.copyWith(
        selectedItem: selectedItem.copyWith(lore: updatedLore),
      );
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
    return state.copyWith(selectedItem: updatedModel);
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
    return state.copyWith(selectedItem: updatedModel);
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
    return state.copyWith(selectedItem: updatedModel);
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
