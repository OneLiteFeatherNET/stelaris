import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/item/item_enchantment_dto.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/paginated_result.dart';
import 'package:stelaris/api/state/app_state.dart';

class ItemEnchantmentFetchAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final selectedItem = state.selectedItem;
    if (selectedItem == null) return null;

    final PaginatedResult<ItemEnchantmentDto> items = selectedItem.enchantments;

    final PaginatedResult<ItemEnchantmentDto> result = await ApiService().itemApi
        .getEnchantments(
      selectedItem.id!,
      page: items.currentPage,
      size: items.pageSize == 0 ? 10 : items.pageSize,
    );
    final updatedItem = selectedItem.copyWith(enchantments: result);
    return state.copyWith(selectedItem: updatedItem);
  }
}

class ItemEnchantmentLoadMoreAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final selectedItem = state.selectedItem;
    if (selectedItem == null) return null;

    final lore = selectedItem.enchantments;
    final isLoading = selectedItem.isLoadingMoreEnchantments;

    // Guards: Exit if already loading, or if there are no items, or no more pages.
    if (isLoading || !lore.hasItems || !lore.hasNextPage) {
      return null;
    }

    dispatch(_SetMoreEnchantmentLoad(true));
    try {
      final nextPage = lore.currentPage + 1;
      final nextResult = await ApiService().itemApi.getEnchantments(
        selectedItem.id!,
        page: nextPage,
        size: lore.pageSize,
      );

      final mergedItems = [...lore.items, ...nextResult.items];

      final updatedEnchantments = lore.copyWith(
        items: mergedItems,
        totalItems: nextResult.totalItems,
        totalPages: nextResult.totalPages,
        currentPage: nextResult.currentPage,
      );

      return state.copyWith(
        selectedItem: selectedItem.copyWith(enchantments: updatedEnchantments),
      );
    } finally {
      dispatch(_SetMoreEnchantmentLoad(false));
    }
  }
}

/// An action that adds a new enchantment to the currently selected item.
///
/// This action sends the given [ItemEnchantmentDto] to the backend, receives
/// the newly created enchantment entry, and updates the selected item with the
/// extended enchantment list.
///
/// If no item is selected, the action does nothing.
///
/// After the new enchantment is applied, the updated item is returned to the
/// state so the UI can immediately reflect the change.
class ItemEnchantmentAddAction extends ReduxAction<AppState> {
  ItemEnchantmentAddAction(this.itemEnchantmentDto);

  /// The enchantment that should be added.
  final ItemEnchantmentDto itemEnchantmentDto;

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;

    final ItemModel itemModel = state.selectedItem!;

    final ItemEnchantmentDto addedEnchantment =
    await ApiService().itemApi.addEnchantment(
      itemModel.id!,
      itemEnchantmentDto,
    );

    final PaginatedResult<ItemEnchantmentDto> enchantments =
        itemModel.enchantments;

    final PaginatedResult<ItemEnchantmentDto> updatedEnchantments =
    enchantments.copyWith(
      items: [...enchantments.items, addedEnchantment],
      totalItems: enchantments.totalItems + 1,
    );

    final ItemModel updatedModel =
    itemModel.copyWith(enchantments: updatedEnchantments);

    return state.copyWith(selectedItem: updatedModel);
  }
}

/// An action that removes an enchantment from the currently selected item.
///
/// This action requests the backend to delete the provided
/// [ItemEnchantmentDto] and updates the selected item by removing the matching
/// enchantment from the local list.
///
/// If no item is selected, the action does nothing.
///
/// Once the enchantment is removed, the updated item is written back into the
/// state so the UI immediately reflects the change.
class ItemEnchantmentDeleteAction extends ReduxAction<AppState> {
  ItemEnchantmentDeleteAction(this.enchantmentDto);

  /// The enchantment that should be removed.
  final ItemEnchantmentDto enchantmentDto;

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;

    final ItemModel itemModel = state.selectedItem!;

    final ItemEnchantmentDto deletedEnchantment =
    await ApiService().itemApi.deleteEnchantment(
      itemModel.id!,
      enchantmentDto,
    );

    final PaginatedResult<ItemEnchantmentDto> enchantments =
        itemModel.enchantments;

    final PaginatedResult<ItemEnchantmentDto> updatedEnchantments =
    enchantments.copyWith(
      items: enchantments.items
          .where((l) => l.id != deletedEnchantment.id)
          .toList(),
      totalItems: enchantments.totalItems - 1,
    );

    final ItemModel updatedModel =
    itemModel.copyWith(enchantments: updatedEnchantments);

    return state.copyWith(selectedItem: updatedModel);
  }
}

/// Internal action to manage the loading state for enchantment pagination.
///
/// This private action toggles the `isLoadingMoreEnchantments` flag on the
/// selected item, preventing multiple parallel fetches of additional pages.
///
/// It is used internally by the enchantment fetch action during pagination.
class _SetMoreEnchantmentLoad extends ReduxAction<AppState> {
  _SetMoreEnchantmentLoad(this.value);

  /// Whether additional enchantments are currently being loaded.
  final bool value;

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;

    final item = state.selectedItem!;
    final updatedItem = item.copyWith(isLoadingMoreEnchantments: value);

    return state.copyWith(selectedItem: updatedItem);
  }
}
