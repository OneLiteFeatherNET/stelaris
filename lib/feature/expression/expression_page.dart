import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression/expression_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/model_card_content.dart';
import 'package:stelaris/feature/model/model_create.dart';
import 'package:stelaris/feature/model/model_notes.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The expression management page: lists the project's expressions through
/// a [ModelPage], creates and deletes them. Tapping one opens its detail
/// route.
class ExpressionPage extends StatelessWidget {
  const ExpressionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ExpressionViewModel>(
      vm: () => ExpressionVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitExpressionAction()),
      builder: (context, vm) {
        return ModelPage<ExpressionModel>(
          entry: NavigationEntry.expression,
          mapToDataModelItem: (value) => ModelCardContent(
            name: value.uiName,
            modelKey: null,
            projectKey: vm.projectKey,
          ),
          deleteTitle: context.l10n.dialog_expression_delete_title,
          mapToDeleteSuccessfully: (value) {
            context.dispatch(ExpressionRemoveAction(value));
            return true;
          },
          models: vm.models,
          nameSelector: (model) => model.uiName,
          keySelector: (model) => '',
          notes: ModelNotes(
            read: (model) => model.comment,
            update: ExpressionNotesUpdateAction.new,
          ),
          projectKey: vm.projectKey,
          matchesFilter: (model, filter) => true,
          onAdd: () => openModelCreateDialog(
            context,
            NavigationEntry.expression,
            vm.projectKey,
          ),
          onModelTap: (model) {
            context.dispatch(SelectExpressionAction(model));
            context.go('${NavigationEntry.expression.route}/detail');
          },
          onRefresh: () => context.dispatch(RefreshExpressionAction()),
          hasMore: vm.hasNextPage,
          isLoadingMore: vm.isLoadingMore,
          onLoadMore: vm.hasNextPage && !vm.isLoadingMore
              ? () => context.dispatch(InitExpressionAction())
              : null,
        );
      },
    );
  }
}
