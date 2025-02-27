import 'dart:ui';

import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/minecraft/enchantment.dart';

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
    final List<ItemModel> items = await ApiService().itemApi.getAll();
    return state.copyWith(items: items);
  }

  InitItemAction();
}

class AddItemAction extends ReduxAction<AppState> {
  final ItemModel _model;

  AddItemAction(this._model);

  @override
  Future<AppState?> reduce() async {
    final ItemModel added = await ApiService().itemApi.add(_model);
    final List<ItemModel> items = List.of(state.items, growable: true);
    items.add(added);
    return state.copyWith(items: items, selectedItem: added);
  }
}

class RemoveItemAction extends ReduxAction<AppState> {
  final ItemModel model;

  RemoveItemAction(this.model);

  @override
  Future<AppState?> reduce() async {
    final ItemModel removedEntry = await ApiService().itemApi.remove(model);
    final List<ItemModel> items = List.of(state.items, growable: true);
    items.removeWhere((element) => element.id == removedEntry.id);
    return state.copyWith(items: items, selectedItem: null);
  }
}

class ItemDatabaseUpdate extends ReduxAction<AppState> {

  ItemDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedItem == null) return null;
    final ItemModel selected = state.selectedItem!;
    final ItemModel dbModel = await ApiService().itemApi.update(selected);
    final List<ItemModel> models = List.of(state.items, growable: true);
    final int index = models.indexWhere((element) => element.id == selected.id);
    models.removeAt(index);
    models.insert(index, dbModel);
    return state.copyWith(items: models, selectedItem: dbModel);
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

    return state.copyWith(
      selectedItem: updatedItem,
    );
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
      final updatedState = state.copyWith(
        selectedItem: updatedItem,
        items: state.items.map((item) {
          if (item.id == updatedItem.id) {
            return updatedItem;
          }
          return item;
        }).toList(),
      );

      return updatedState;
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

    return state.copyWith(
      selectedItem: updatedItem,
    );
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

    return state.copyWith(
      selectedItem: updatedItem,
    );
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

    return state.copyWith(
      selectedItem: updatedItem,
    );
  }

  @override
  void after() {
    if (onComplete != null) {
      onComplete!();
    }
  }
}
