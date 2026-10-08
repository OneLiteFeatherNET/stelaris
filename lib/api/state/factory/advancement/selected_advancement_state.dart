import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/advancement/advancement_page_general.dart';

class SelectedAdvancementFactory
    extends
        VmFactory<AppState, AdvancementGeneralPage, SelectedAdvancementView> {
  SelectedAdvancementFactory();

  @override
  SelectedAdvancementView fromStore() =>
      SelectedAdvancementView(selected: state.selectedAdvancement!);
}

class SelectedAdvancementView extends Vm {
  SelectedAdvancementView({required this.selected}) : super(equals: [selected]);

  final AdvancementModel selected;
}
