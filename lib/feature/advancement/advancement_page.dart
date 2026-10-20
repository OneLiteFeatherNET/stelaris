import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/advancement_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/advancement/advancement_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/model_card_content.dart';
import 'package:stelaris/feature/model/model_create.dart';
import 'package:stelaris/feature/model/model_notes.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/feature/model/model_copy.dart';

/// A widget that represents the advancement management page.
///
/// The [AdvancementPage] allows users to view, search, and manage
/// advancements through a [ModelPage]. It provides a dialog for creating
/// new advancements and handles the state management through Redux.
/// Tapping an advancement navigates to its dedicated detail route, since an
/// advancement has more fields than would comfortably fit in a small dialog.
class AdvancementPage extends StatelessWidget {
  const AdvancementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AdvancementViewModel>(
      vm: () => AdvancementVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitAdvancementAction()),
      builder: (context, vm) {
        return ModelPage<AdvancementModel>(
          entry: NavigationEntry.advancements,
          mapToDataModelItem: (value) => ModelCardContent(
            name: value.uiName,
            modelKey: value.key,
            projectKey: vm.projectKey,
          ),
          deleteTitle: context.l10n.dialog_advancement_delete_title,
          mapToDeleteSuccessfully: (value) {
            context.dispatch(AdvancementRemoveAction(value));
            return true;
          },
          models: vm.models,
          nameSelector: (model) => model.uiName,
          keySelector: (model) => model.key ?? '',
          notes: ModelNotes(
            read: (model) => model.comment,
            update: AdvancementNotesUpdateAction.new,
          ),
          copy: ModelCopy(
            title: (l10n) => l10n.dialog_advancement_copy,
            action: AdvancementCopyAction.new,
          ),
          projectKey: vm.projectKey,
          matchesFilter: (model, filter) => true,
          onAdd: () => openModelCreateDialog(
            context,
            NavigationEntry.advancements,
            vm.projectKey,
          ),
          onModelTap: (model) {
            context.dispatch(SelectedAdvancementAction(model));
            context.go('${NavigationEntry.advancements.route}/detail');
          },
          onRefresh: () => context.dispatch(RefreshAdvancementAction()),
          hasMore: vm.hasNextPage,
          isLoadingMore: vm.isLoadingMore,
          onLoadMore: vm.hasNextPage && !vm.isLoadingMore
              ? () => context.dispatch(InitAdvancementAction())
              : null,
        );
      },
    );
  }
}
