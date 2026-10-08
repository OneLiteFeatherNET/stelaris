import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/advancement/advancement_page_general.dart';

class SelectedAdvancementFactory
    extends
        VmFactory<AppState, AdvancementGeneralPage, SelectedAdvancementView> {
  SelectedAdvancementFactory();

  @override
  SelectedAdvancementView fromStore() {
    final selected = state.selectedAdvancement!;
    final items = state.advancements.items;
    final excluded = _descendantsOf(selected.id, items)..add(selected.id);
    return SelectedAdvancementView(
      selected: selected,
      parents: [
        for (final model in items)
          if (model.id != null && !excluded.contains(model.id)) model,
      ],
    );
  }
}

class SelectedAdvancementView extends Vm {
  SelectedAdvancementView({required this.selected, required this.parents})
    : super(equals: [selected, parents]);

  final AdvancementModel selected;

  /// The loaded advancements the selected one can use as its parent.
  final List<AdvancementModel> parents;
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
