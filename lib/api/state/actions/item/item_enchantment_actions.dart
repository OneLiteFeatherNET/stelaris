import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/paginated_loading.dart';
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

    // Apply to the item as it is now: the group may have been changed while
    // the request was running, and another item may have been selected.
    final latest = state.selectedItem;
    if (latest == null || latest.id != selectedItem.id) return null;
    return state.copyWith(selectedItem: latest.copyWith(enchantments: result));
  }
}

/// Appends the next page of enchantments to the selected item, if there is
/// one.
///
/// While it loads, `isWaiting(ItemEnchantmentLoadMoreAction)` is true, and
/// another one dispatched meanwhile is dropped.
class ItemEnchantmentLoadMoreAction extends ReduxAction<AppState>
    with NonReentrant {
  @override
  Future<AppState?> reduce() async {
    final selectedItem = state.selectedItem;
    if (selectedItem == null) return null;

    final enchantments = selectedItem.enchantments;
    if (!enchantments.hasItems || !enchantments.hasNextPage) return null;

    final next = await ApiService().itemApi.getEnchantments(
      selectedItem.id!,
      page: enchantments.currentPage + 1,
      size: enchantments.pageSize,
    );

    // Another item was selected, or the enchantments of this one changed,
    // while the page loaded, so the page no longer continues them.
    final item = state.selectedItem;
    if (item == null ||
        item.id != selectedItem.id ||
        !identical(item.enchantments, enchantments)) {
      return null;
    }

    final updatedEnchantments = enchantments.copyWith(
      items: [...enchantments.items, ...next.items],
      totalItems: next.totalItems,
      totalPages: next.totalPages,
      currentPage: next.currentPage,
    );

    // Built on the current item, so form edits made while the page loaded
    // are kept.
    return state.copyWith(
      selectedItem: item.copyWith(enchantments: updatedEnchantments),
    );
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

    final updated = selectedItem.copyWith(
      enchantments: selectedItem.enchantments.adding(added),
    );

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

    final updated = selectedItem.copyWith(
      enchantments: selectedItem.enchantments.removingWhere(
        (x) => x.id == removed.id,
      ),
    );

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

    final updated = selectedItem.copyWith(
      enchantments: selectedItem.enchantments.replacingWhere(
        (e) => e.id == updatedEnchantment.id,
        updatedEnchantment,
      ),
    );

    return state.copyWith(selectedItem: updated);
  }
}
