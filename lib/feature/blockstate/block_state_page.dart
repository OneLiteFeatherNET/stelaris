import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/block_state_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/blockstate/block_state_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/blockstate/block_state_create_dialog.dart';
import 'package:stelaris/feature/model/model_card_content.dart';
import 'package:stelaris/feature/model/model_notes.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The namespace of every block a blockstate can be made for. The cards show
/// the block key instead of a key in the project, so they put this in front.
const String blockNamespace = 'minecraft';

/// The path of a block key, e.g. `pink_petals` for `minecraft:pink_petals`.
String blockPath(String? key) {
  final value = key ?? '';
  final colon = value.indexOf(':');
  return colon < 0 ? value : value.substring(colon + 1);
}

/// The blockstates of the project as a grid of cards. A tap opens one on its
/// detail route, as for the other models.
///
/// Every blockstate is a context of a block: its name and its block are
/// fixed once it is created, its notes are edited from the card, so what is
/// left to edit on the detail page are its rules.
class BlockStatePage extends StatelessWidget {
  const BlockStatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, BlockStateViewModel>(
      vm: () => BlockStateVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitBlockStateAction()),
      builder: (context, vm) {
        final isLoadingMore = context.isWaiting(LoadMoreBlockStatesAction);
        final l10n = context.l10n;
        return ModelPage<BlockStateModel>(
          entry: NavigationEntry.blockstates,
          mapToDataModelItem: (value) => ModelCardContent(
            name: value.uiName,
            modelKey: blockPath(value.key),
            projectKey: blockNamespace,
          ),
          deleteTitle: l10n.blockstate_delete_title,
          deleteWarning: l10n.blockstate_delete_warning,
          mapToDeleteSuccessfully: (value) {
            context.dispatch(BlockStateRemoveAction(value));
            return true;
          },
          models: vm.models,
          nameSelector: (model) => model.uiName,
          keySelector: (model) => blockPath(model.key),
          notes: ModelNotes(
            read: (model) => model.comment,
            update: BlockStateNotesUpdateAction.new,
          ),
          projectKey: blockNamespace,
          matchesFilter: (_, _) => true,
          onAdd: () => openBlockStateCreateDialog(context),
          onModelTap: (model) {
            context.dispatch(SelectBlockStateAction(model));
            context.go('${NavigationEntry.blockstates.route}/detail');
          },
          onRefresh: () => context.dispatch(RefreshBlockStateAction()),
          hasMore: vm.hasNextPage,
          isLoadingMore: isLoadingMore,
          onLoadMore: vm.hasNextPage && !isLoadingMore
              ? () => context.dispatch(LoadMoreBlockStatesAction())
              : null,
        );
      },
    );
  }
}
