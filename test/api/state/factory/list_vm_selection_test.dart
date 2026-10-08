import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/attribute/attribute_vm_state.dart';
import 'package:stelaris/api/state/factory/font/font_vm_state.dart';
import 'package:stelaris/api/state/factory/item/item_vm_state.dart';
import 'package:stelaris/api/state/factory/advancement/advancement_vm_state.dart';
import 'package:stelaris/api/state/factory/sound/sound_vm_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The list pages stay mounted under their detail page, so a view model
/// that changed with the selection would rebuild the whole list each time
/// an entry is opened or closed.
void main() {
  const base = AppState(
    selectedProject: Project(displayName: 'P', id: 'proj-1', key: 'p'),
  );

  /// Whether [factory]'s view model is the same with and without [selected].
  bool unchangedBySelection(
    VmFactory<AppState, Widget?, Vm> Function() factory,
    AppState selected,
  ) {
    final before = Vm.createFrom(
      Store<AppState>(initialState: base),
      factory(),
    );
    final after = Vm.createFrom(
      Store<AppState>(initialState: selected),
      factory(),
    );
    return before == after;
  }

  group('list view models ignore the selection', () {
    test('items', () {
      expect(
        unchangedBySelection(
          ItemVmFactory.new,
          base.copyWith(selectedItem: const ItemModel(uiName: 'Sword')),
        ),
        isTrue,
      );
    });

    test('fonts', () {
      expect(
        unchangedBySelection(
          FontVmFactory.new,
          base.copyWith(selectedFont: const FontModel(uiName: 'Runes')),
        ),
        isTrue,
      );
    });

    test('sounds', () {
      expect(
        unchangedBySelection(
          SoundVmFactory.new,
          base.copyWith(selectedSoundEvent: SoundEventModel(uiName: 'Break')),
        ),
        isTrue,
      );
    });

    test('advancements', () {
      expect(
        unchangedBySelection(
          AdvancementVmFactory.new,
          base.copyWith(
            selectedAdvancement: const AdvancementModel(uiName: 'Done'),
          ),
        ),
        isTrue,
      );
    });

    test('attributes', () {
      expect(
        unchangedBySelection(
          AttributeVmFactory.new,
          base.copyWith(
            selectedAttribute: const AttributeModel(uiName: 'Mana'),
          ),
        ),
        isTrue,
      );
    });
  });
}
