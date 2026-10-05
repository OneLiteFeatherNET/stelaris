import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Loads all data components of the selected item.
///
/// An item only has a handful of components, so every page is loaded at once
/// instead of paginating like the enchantments.
class ItemComponentFetchAction extends ReduxAction<AppState> with NonReentrant {
  @override
  Future<AppState?> reduce() async {
    final selectedItem = state.selectedItem;
    if (selectedItem == null) return null;

    final components = <ItemComponentDto>[];
    var page = 1;
    while (true) {
      final result = await ApiService().itemApi.getComponents(
        selectedItem.id!,
        page: page,
      );
      components.addAll(result.items);
      // Counted here instead of trusting currentPage, which a backend may
      // number from 0 or 1.
      if (result.items.isEmpty || page >= result.totalPages) break;
      page++;
    }

    // The user may have switched to another item while loading.
    if (state.selectedItem?.id != selectedItem.id) return null;
    return state.copyWith(selectedItemComponents: components);
  }
}

/// Adds a data component to the selected item.
class ItemComponentAddAction extends ReduxAction<AppState> with NonReentrant {
  ItemComponentAddAction(this.component);

  /// The component to add, without an id.
  final ItemComponentDto component;

  /// Different components can be added at the same time, the same one not.
  @override
  Object? nonReentrantKeyParams() => component.componentKey;

  @override
  Future<AppState?> reduce() async {
    final selectedItem = state.selectedItem;
    if (selectedItem == null) return null;

    final added = await ApiService().itemApi.addComponent(
      selectedItem.id!,
      component,
    );

    return state.copyWith(
      selectedItemComponents: [...state.selectedItemComponents, added],
    );
  }
}

/// Updates a data component of the selected item.
class ItemComponentUpdateAction extends ReduxAction<AppState>
    with NonReentrant {
  ItemComponentUpdateAction(this.component);

  /// The component with its id and the new value.
  final ItemComponentDto component;

  @override
  Object? nonReentrantKeyParams() => component.id;

  @override
  Future<AppState?> reduce() async {
    final selectedItem = state.selectedItem;
    if (selectedItem == null) return null;

    final updated = await ApiService().itemApi.updateComponent(
      selectedItem.id!,
      component,
    );

    return state.copyWith(
      selectedItemComponents: [
        for (final entry in state.selectedItemComponents)
          entry.id == updated.id ? updated : entry,
      ],
    );
  }
}

/// Removes a data component from the selected item.
class ItemComponentDeleteAction extends ReduxAction<AppState>
    with NonReentrant {
  ItemComponentDeleteAction(this.component);

  /// The component to remove.
  final ItemComponentDto component;

  @override
  Object? nonReentrantKeyParams() => component.id;

  @override
  Future<AppState?> reduce() async {
    final selectedItem = state.selectedItem;
    if (selectedItem == null) return null;

    final removed = await ApiService().itemApi.deleteComponent(
      selectedItem.id!,
      component,
    );

    return state.copyWith(
      selectedItemComponents: [
        for (final entry in state.selectedItemComponents)
          if (entry.id != removed.id) entry,
      ],
    );
  }
}
