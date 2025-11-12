import 'dart:ui';

import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/item/item_enchantment_model.dart';
import 'package:stelaris/api/model/item/item_flag_model.dart';
import 'package:stelaris/api/model/item/item_lore_model.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/paginated_result.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:vulpes_data/api/enchantment.dart';

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

class ItemFlagResetAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;
    final ItemModel oldEntry = state.selectedItem!;
    if (oldEntry.flags == null) return null;
    return state.copyWith(selectedItem: oldEntry.copyWith(flags: {}));
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
        final next = await ApiService().itemApi.getPage(page: nextPage, size: size);

        final merged = List<ItemModel>.of(current.items)..addAll(next.items);
        final updated = current.copyWith(
          items: merged,
          totalItems: next.totalItems != 0 ? next.totalItems : current.totalItems,
          totalPages: next.totalPages != 0 ? next.totalPages : current.totalPages,
          currentPage: next.currentPage != 0 ? next.currentPage : nextPage,
          pageSize: next.pageSize != 0 ? next.pageSize : size,
        );
        return state.copyWith(items: updated);
      } finally {
        dispatchSync(_SetLoadMoreItemModels(false));
      }
    } else {
      // Initial load (or refresh)
      final PaginatedResult<ItemModel> result =
      await ApiService().itemApi.getPage(page: 1, size: state.items.pageSize == 0 ? 10 : state.items.pageSize);
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
    return _updateItemInState(state, items, added, totalItems: items.length);
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

    final List<ItemModel> updatedList = List.of(
      state.items.items,
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

// Actions for state management
class AddEnchantmentAction extends ReduxAction<AppState> {
  final Enchantment enchantment;
  final int level;

  AddEnchantmentAction({required this.enchantment, required this.level});

  @override
  AppState reduce() {
    final selectedItem = state.selectedItem!;
    final enchantments = Map<String, int>.from(selectedItem.enchantments ?? {});
    enchantments[enchantment.minecraftValue] = level;

    final updatedItem = selectedItem.copyWith(enchantments: enchantments);

    return state.copyWith(selectedItem: updatedItem);
  }
}

class SaveEnchantmentsAction extends ReduxAction<AppState> {
  final Function? onSuccess;
  final Function(dynamic)? onError;

  SaveEnchantmentsAction({this.onSuccess, this.onError});

  @override
  Future<AppState> reduce() async {
    final selectedItem = state.selectedItem!;

    try {
      // Call the API to update the item with enchantments
      final updatedItem = await ApiService().itemApi.update(selectedItem);

      // Update the items list with the updated item from the server
      final List<ItemModel> updatedList = List.of(
        state.items.items,
        growable: true,
      );
      final int index = updatedList.indexWhere(
        (element) => element.id == selectedItem.id,
      );

      if (index != -1) {
        updatedList[index] = updatedItem;
      }
      return _updateItemInState(state, updatedList, updatedItem);
    } catch (e) {
      // Call the error callback if provided
      if (onError != null) {
        onError!(e);
      }
      // Return unchanged state on error
      return state;
    }
  }

  @override
  void after() {
    // Call the success callback if no error occurred
    if (onSuccess != null) {
      onSuccess!();
    }
  }
}

class UpdateEnchantmentLevelAction extends ReduxAction<AppState> {
  final Enchantment enchantment;
  final int level;

  UpdateEnchantmentLevelAction({
    required this.enchantment,
    required this.level,
  });

  @override
  AppState reduce() {
    final selectedItem = state.selectedItem!;
    final enchantments = Map<String, int>.from(selectedItem.enchantments ?? {});
    enchantments[enchantment.minecraftValue] = level;

    final updatedItem = selectedItem.copyWith(enchantments: enchantments);

    return state.copyWith(selectedItem: updatedItem);
  }
}

class DeleteEnchantmentAction extends ReduxAction<AppState> {
  final Enchantment enchantment;
  final VoidCallback? onComplete;

  DeleteEnchantmentAction({required this.enchantment, this.onComplete});

  @override
  AppState reduce() {
    final selectedItem = state.selectedItem!;
    final enchantments = Map<String, int>.from(selectedItem.enchantments ?? {});
    enchantments.remove(enchantment.minecraftValue);

    final updatedItem = selectedItem.copyWith(enchantments: enchantments);

    return state.copyWith(selectedItem: updatedItem);
  }

  @override
  void after() {
    if (onComplete != null) {
      onComplete!();
    }
  }
}

class ResetEnchantmentsAction extends ReduxAction<AppState> {
  final VoidCallback? onComplete;

  ResetEnchantmentsAction({this.onComplete});

  @override
  AppState reduce() {
    final selectedItem = state.selectedItem!;
    final updatedItem = selectedItem.copyWith(enchantments: {});

    return state.copyWith(selectedItem: updatedItem);
  }

  @override
  void after() {
    if (onComplete != null) {
      onComplete!();
    }
  }
}

/// Fetches lore for the selected item and appends it to existing lore.
/// Requires the id of the [ItemModel] to fetch the lore for it.
class ItemLoreFetchAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;
    final ItemModel selected = state.selectedItem!;
    final ItemLoreModel lore = await ApiService().itemApi.getLore(selected.id!);
    final ItemModel updatedItem = selected.copyWith(lore: lore.lore);
    return state.copyWith(selectedItem: updatedItem);
  }
}

/// Fetches enchantments for the selected item and appends it to existing enchantments.
/// Requires the id of the [ItemModel] to fetch the enchantments for it.
class ItemEnchantmentFetchAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;
    final ItemModel selected = state.selectedItem!;
    final ItemEnchantmentModel dbModel = await ApiService().itemApi
        .getEnchantments(selected.id!);
    final ItemModel updatedItem = selected.copyWith(
      enchantments: dbModel.enchantments,
    );
    return state.copyWith(selectedItem: updatedItem);
  }
}

class ItemFlagFetchAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;
    final ItemModel selected = state.selectedItem!;
    final ItemFlagModel dbModel = await ApiService().itemApi.getFlags(
      selected.id!,
    );
    final ItemModel updatedItem = selected.copyWith(flags: dbModel.flags);
    return state.copyWith(selectedItem: updatedItem);
  }
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
