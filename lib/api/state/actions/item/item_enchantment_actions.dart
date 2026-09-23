import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';

class ItemEnchantmentFetchAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final selectedItem = state.selectedItem;
    if (selectedItem == null) return null;

    final current = selectedItem.enchantments;

    final result = await ApiService().itemApi.getEnchantments(
      selectedItem.id!,
      page: current.currentPage,
      size: current.pageSize == 0 ? 5 : current.pageSize,
    );

    // result is already safe and immutable
    final updated = selectedItem.copyWith(enchantments: result);
    return state.copyWith(selectedItem: updated);
  }
}

class ItemEnchantmentLoadMoreAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final selectedItem = state.selectedItem;
    if (selectedItem == null) return null;

    final enchantments = selectedItem.enchantments;
    if (selectedItem.isLoadingMoreEnchantments ||
        !enchantments.hasItems ||
        !enchantments.hasNextPage) {
      return null;
    }

    dispatch(_SetMoreEnchantmentLoad(true));
    try {
      final nextPage = enchantments.currentPage + 1;

      final next = await ApiService().itemApi.getEnchantments(
        selectedItem.id!,
        page: nextPage,
        size: enchantments.pageSize,
      );

      final mergedItems = [...enchantments.items, ...next.items]; // safe clone

      final updatedEnchantments = enchantments.copyWith(
        items: mergedItems,
        totalItems: next.totalItems,
        totalPages: next.totalPages,
        currentPage: next.currentPage,
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

  final ItemEnchantmentDto itemEnchantmentDto;

  @override
  Future<AppState?> reduce() async {
    final selectedItem = state.selectedItem;
    if (selectedItem == null) return null;

    final added = await ApiService().itemApi.addEnchantment(
      selectedItem.id!,
      itemEnchantmentDto,
    );

    final ench = selectedItem.enchantments;

    final updatedEnchantments = ench.copyWith(
      items: [...ench.items, added], // clone & append
      totalItems: ench.totalItems + 1,
    );

    final updated = selectedItem.copyWith(enchantments: updatedEnchantments);

    return state.copyWith(selectedItem: updated);
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

  final ItemEnchantmentDto enchantmentDto;

  @override
  Future<AppState?> reduce() async {
    final selectedItem = state.selectedItem;
    if (selectedItem == null) return null;

    final removed = await ApiService().itemApi.deleteEnchantment(
      selectedItem.id!,
      enchantmentDto,
    );

    final ench = selectedItem.enchantments;

    final updatedEnchantments = ench.copyWith(
      items: ench.items.where((x) => x.id != removed.id).toList(),
      totalItems: ench.totalItems - 1,
    );

    final updated = selectedItem.copyWith(enchantments: updatedEnchantments);

    return state.copyWith(selectedItem: updated);
  }
}

/// An action that updates an existing enchantment of the currently selected item.
///
/// This action sends the given [ItemEnchantmentDto] to the backend, receives
/// the newly updated enchantment entry, and updates the selected item with the
/// modified enchantment in the list.
///
/// If no item is selected, the action does nothing.
///
/// After the enchantment is updated, the updated item is returned to the
/// state so the UI can immediately reflect the change.
class ItemEnchantmentUpdateAction extends ReduxAction<AppState> {
  ItemEnchantmentUpdateAction(this.itemEnchantmentDto);

  final ItemEnchantmentDto itemEnchantmentDto;

  @override
  Future<AppState?> reduce() async {
    final selectedItem = state.selectedItem;
    if (selectedItem == null) return null;

    final updatedEnchantment = await ApiService().itemApi.updateEnchantment(
      selectedItem.id!,
      itemEnchantmentDto,
    );

    final ench = selectedItem.enchantments;

    final updatedList = ench.items
        .map((e) => e.id == updatedEnchantment.id ? updatedEnchantment : e)
        .toList();

    final updatedEnchantments = ench.copyWith(items: updatedList);

    final updated = selectedItem.copyWith(enchantments: updatedEnchantments);

    return state.copyWith(selectedItem: updated);
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
