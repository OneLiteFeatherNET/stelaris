import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/block_state_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/blockstate/selected_block_state_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/blockstate/block_state_page.dart';
import 'package:stelaris/feature/blockstate/block_state_rule_grid.dart';
import 'package:stelaris/feature/blockstate/block_state_rules.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Puts [blockState] into the store and marks the page unsaved. The header's
/// save sends it to the backend.
void _stage(BuildContext context, BlockStateModel blockState) =>
    context.dispatch(UpdateBlockStateAction(blockState));

/// The detail view reached by tapping a blockstate card in [BlockStatePage]:
/// the shared [ModelDetailShell] header with an action to add a rule, and
/// the rules below it.
class BlockStateDetailPage extends StatelessWidget {
  const BlockStateDetailPage({super.key});

  /// Appends the rule of the dialog to the selected blockstate. The dialog
  /// is modal, so the selection is still the same when it closes.
  static Future<void> _addRule(BuildContext context) async {
    final selected = StoreProvider.state<AppState>(
      context,
      notify: false,
    ).selectedBlockState;
    if (selected == null) return;
    final rule = await showRuleDialog(
      context,
      index: selected.rules.length,
      spec: specFor(selected.key),
      rule: const BlockStateRule(),
    );
    if (rule == null || !context.mounted) return;
    _stage(context, selected.copyWith(rules: [...selected.rules, rule]));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StoreConnector<AppState, _BlockStateTitleView>(
      vm: () => _BlockStateTitleFactory(),
      onDispose: (store) =>
          store.dispatch(RemoveSelectBlockStateAction(), notify: false),
      builder: (context, vm) => ModelDetailShell(
        entry: NavigationEntry.blockstates,
        title: vm.title,
        actions: [
          PageHeaderAction(
            icon: addModelIcon,
            label: l10n.blockstate_rule_add,
            primary: true,
            onPressed: () => _addRule(context),
          ),
          ModelDetailActions<BlockStateModel>(
            entry: NavigationEntry.blockstates,
            selectModel: (state) => state.selectedBlockState,
            nameSelector: (model) => model.uiName,
            keySelector: (model) => blockPath(model.key),
            namespace: blockNamespace,
            deleteTitle: l10n.blockstate_delete_title,
            deleteWarning: l10n.blockstate_delete_warning,
            removeAction: BlockStateRemoveAction.new,
            readNotes: (model) => model.comment,
          ),
        ],
        body: const BlockStateRules(),
      ),
    );
  }
}

/// The rules of the selected blockstate. A change is staged until the
/// header's save.
class BlockStateRules extends StatelessWidget {
  const BlockStateRules({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedBlockStateView>(
      vm: () => SelectedBlockStateFactory(),
      builder: (context, vm) => BlockStateRuleGrid(
        entry: vm.selected,
        others: vm.others,
        onChanged: (blockState) => _stage(context, blockState),
      ),
    );
  }
}

class _BlockStateTitleView extends Vm {
  _BlockStateTitleView({required this.title}) : super(equals: [title]);

  final String? title;
}

class _BlockStateTitleFactory
    extends VmFactory<AppState, BlockStateDetailPage, _BlockStateTitleView> {
  @override
  _BlockStateTitleView fromStore() =>
      _BlockStateTitleView(title: state.selectedBlockState?.uiName);
}
