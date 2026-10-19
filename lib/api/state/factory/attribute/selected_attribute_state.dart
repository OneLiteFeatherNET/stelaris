import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/attributes/attribute_general_page.dart';

class SelectedAttributeFactory
    extends VmFactory<AppState, AttributeGeneralPage, SelectedAttributeView> {
  SelectedAttributeFactory();

  @override
  SelectedAttributeView fromStore() =>
      SelectedAttributeView(selected: state.selectedAttribute!);
}

class SelectedAttributeView extends Vm {
  SelectedAttributeView({required this.selected}) : super(equals: [selected]);

  final AttributeModel selected;
}
