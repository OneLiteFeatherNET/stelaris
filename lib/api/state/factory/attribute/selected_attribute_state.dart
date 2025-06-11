import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/model/attribute_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/attributes/attribute_page.dart';

class SelectedAttributeFactory
    extends VmFactory<AppState, AttributePage, SelectedAttributeView> {
  SelectedAttributeFactory();

  @override
  SelectedAttributeView fromStore() =>
      SelectedAttributeView(selected: state.selectedAttribute!);
}

class SelectedAttributeView extends Vm {
  SelectedAttributeView({required this.selected}) : super(equals: [selected]);

  final AttributeModel selected;

}
