import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/advancement/advancement_page_general.dart';

class SelectedAdvancementFactory
    extends
        VmFactory<AppState, AdvancementGeneralPage, SelectedAdvancementView> {
  SelectedAdvancementFactory();

  @override
  SelectedAdvancementView fromStore() => SelectedAdvancementView(
    selected: state.selectedAdvancement!,
    items: state.advancements.items,
  );
}

class SelectedAdvancementView extends Vm {
  /// Compares [items] by identity: the state only replaces the list when the
  /// loaded advancements change, so other dispatches don't rebuild the page.
  SelectedAdvancementView({required this.selected, required this.items})
    : super(equals: [selected, items]);

  final AdvancementModel selected;

  /// The loaded advancements.
  final List<AdvancementModel> items;

  /// The loaded advancements the selected one can use as its parent.
  late final List<AdvancementModel> parents = () {
    final excluded = _descendantsOf(selected.id, items)..add(selected.id);
    return [
      for (final model in items)
        if (model.id != null && !excluded.contains(model.id)) model,
    ];
  }();
}

/// Returns the ids of all loaded advancements below [id], which can't become
/// its parent without creating a cycle.
Set<String?> _descendantsOf(String? id, List<AdvancementModel> items) {
  final descendants = <String?>{};
  if (id == null) return descendants;
  final pending = [id];
  while (pending.isNotEmpty) {
    final parent = pending.removeLast();
    for (final model in items) {
      if (model.parentId == parent && descendants.add(model.id)) {
        if (model.id != null) pending.add(model.id!);
      }
    }
  }
  return descendants;
}
