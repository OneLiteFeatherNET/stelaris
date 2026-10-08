import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/advancement/selected_advancement_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The detail page rebuilds whenever its view model changes, so a dispatch
/// that leaves the advancements alone must keep the view model equal.
void main() {
  const selected = AdvancementModel(id: 'adv-1', uiName: 'Root');

  const base = AppState(selectedAdvancement: selected);

  SelectedAdvancementView viewOf(AppState state) => Vm.createFrom(
    Store<AppState>(initialState: state),
    SelectedAdvancementFactory(),
  );

  test('an unrelated change keeps the view model equal', () {
    final changed = base.copyWith(unsavedChanges: NavigationEntry.advancements);

    expect(viewOf(changed), viewOf(base));
  });

  test('a changed selection changes the view model', () {
    final changed = base.copyWith(
      selectedAdvancement: selected.copyWith(hidden: true),
    );

    expect(viewOf(changed), isNot(viewOf(base)));
  });
}
