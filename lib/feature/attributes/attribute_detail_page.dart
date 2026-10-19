import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/attributes/attribute_general_page.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The detail view reached by tapping an attribute card in [AttributePage].
///
/// Shows the shared [ModelDetailShell] header row with its actions and the
/// [AttributeGeneralPage] below it.
class AttributeDetailPage extends StatelessWidget {
  const AttributeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _AttributeTitleView>(
      vm: () => _AttributeTitleFactory(),
      onDispose: (store) =>
          store.dispatch(RemoveSelectAttributeAction(), notify: false),
      builder: (context, vm) => ModelDetailShell(
        entry: NavigationEntry.attributes,
        title: vm.title,
        actions: [
          ModelDetailActions<AttributeModel>(
            entry: NavigationEntry.attributes,
            selectModel: (state) => state.selectedAttribute,
            nameSelector: (model) => model.uiName,
            keySelector: (model) => model.key ?? '',
            deleteTitle: context.l10n.dialog_attribute_delete_title,
            removeAction: AttributeRemoveAction.new,
            readNotes: (model) => model.comment,
            shareLocation: (state) => switch (state.selectedAttribute) {
              final AttributeModel model? => detailLocation(
                NavigationEntry.attributes.route,
                projectId: model.projectId ?? state.selectedProject?.id,
                id: model.id,
              ),
              null => null,
            },
          ),
        ],
        body: const AttributeGeneralPage(),
      ),
    );
  }
}

class _AttributeTitleView extends Vm {
  _AttributeTitleView({required this.title}) : super(equals: [title]);

  final String? title;
}

class _AttributeTitleFactory
    extends VmFactory<AppState, AttributeDetailPage, _AttributeTitleView> {
  @override
  _AttributeTitleView fromStore() =>
      _AttributeTitleView(title: state.selectedAttribute?.uiName);
}
