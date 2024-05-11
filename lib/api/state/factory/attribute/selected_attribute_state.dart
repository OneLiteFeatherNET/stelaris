import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/model/attribute_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/attributes/attribute_page.dart';
import 'package:stelaris_ui/util/constants.dart';

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

  String get name => selected.name ?? unknownEntry;
}
