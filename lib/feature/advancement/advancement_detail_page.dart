import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/advancement_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/feature/advancement/advancement_page_general.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The detail view reached by tapping a advancement card in [AdvancementPage].
///
/// Shows the shared [ModelDetailShell] header row with its actions, with the existing
/// [AdvancementGeneralPage] form below it unchanged.
class AdvancementDetailPage extends StatelessWidget {
  const AdvancementDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _AdvancementTitleView>(
      vm: () => _AdvancementTitleFactory(),
      onDispose: (store) =>
          store.dispatch(RemoveSelectAdvancementAction(), notify: false),
      builder: (context, vm) => ModelDetailShell(
        entry: NavigationEntry.advancements,
        title: vm.title,
        actions: [
          ModelDetailActions<AdvancementModel>(
            entry: NavigationEntry.advancements,
            selectModel: (state) => state.selectedAdvancement,
            nameSelector: (model) => model.uiName,
            keySelector: (model) => model.key ?? '',
            deleteTitle: context.l10n.dialog_advancement_delete_title,
            removeAction: AdvancementRemoveAction.new,
            readNotes: (model) => model.comment,
          ),
        ],
        body: const AdvancementGeneralPage(),
      ),
    );
  }
}

class _AdvancementTitleView extends Vm {
  _AdvancementTitleView({required this.title}) : super(equals: [title]);

  final String? title;
}

class _AdvancementTitleFactory
    extends VmFactory<AppState, AdvancementDetailPage, _AdvancementTitleView> {
  @override
  _AdvancementTitleView fromStore() =>
      _AdvancementTitleView(title: state.selectedAdvancement?.uiName);
}
