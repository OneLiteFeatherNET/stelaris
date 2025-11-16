import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/item/item_enchantment_dto.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/paginated_result.dart';
import 'package:stelaris/api/state/app_state.dart';

/// An action that loads enchantments for the currently selected item.
///
/// This action supports two loading modes:
///
/// * **Load more** – If the item already has enchantments loaded and additional
///   pages exist, it fetches the next page and merges the results into the
///   existing list.
///
/// * **Initial fetch** – If no enchantments have been loaded yet (or a refresh
///   is needed), it loads the first page.
///
/// To prevent multiple parallel requests, a temporary loading flag is set on
/// the item while additional pages are being fetched.
///
/// If no item is selected, the action does nothing.
class ItemEnchantmentFetchAction extends ReduxAction<AppState> {
  ItemEnchantmentFetchAction();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;

    final ItemModel itemModel = state.selectedItem!;

    final hasExisting = itemModel.enchantments.hasItems;
    final canLoadMore = itemModel.enchantments.hasNextPage;

    if (hasExisting && canLoadMore) {
      // Load the next page
      if (state.isLoadingMoreItems) return null;
      dispatchSync(_SetMoreEnchantmentLoad(true));

      try {
        final current = itemModel.enchantments;
        final nextPage = current.currentPage + 1;
        final size = 10;

        final next = await ApiService().itemApi.getEnchantments(
          itemModel.id!,
          page: nextPage,
          size: size,
        );

        final merged = List<ItemEnchantmentDto>.of(current.items)
          ..addAll(next.items);

        final updated = itemModel.copyWith(
          enchantments: current.copyWith(
            items: merged,
            totalItems:
            next.totalItems != 0 ? next.totalItems : current.totalItems,
            totalPages:
            next.totalPages != 0 ? next.totalPages : current.totalPages,
            currentPage:
            next.currentPage != 0 ? next.currentPage : nextPage,
            pageSize: next.pageSize != 0 ? next.pageSize : size,
          ),
        );

        return state.copyWith(selectedItem: updated);
      } finally {
        dispatchSync(_SetMoreEnchantmentLoad(false));
      }
    } else {
      // Initial load or refresh
      final PaginatedResult<ItemEnchantmentDto> result =
      await ApiService().itemApi.getEnchantments(
        itemModel.id!,
        page: 1,
        size: itemModel.enchantments.pageSize == 0
            ? 10
            : itemModel.enchantments.pageSize,
      );

      final ItemModel updated =
      itemModel.copyWith(enchantments: result);

      return state.copyWith(selectedItem: updated);
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
