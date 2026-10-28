import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/expression_function_model.dart';
import 'package:stelaris/api/state/actions/expression/expression_function_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression_function/expression_function_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/model_create.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The project's functions: lists them through a [ModelPage], creates and
/// deletes them. Tapping one opens its detail route.
class ExpressionFunctionPage extends StatelessWidget {
  const ExpressionFunctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ExpressionFunctionViewModel>(
      vm: () => ExpressionFunctionVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitExpressionFunctionAction()),
      builder: (context, vm) {
        return ModelPage<ExpressionFunctionModel>(
          entry: NavigationEntry.function,
          mapToDataModelItem: (value) => _FunctionCardContent(function: value),
          deleteTitle: context.l10n.dialog_expression_function_delete_title,
          mapToDeleteSuccessfully: (value) {
            context.dispatch(ExpressionFunctionRemoveAction(value));
            return true;
          },
          models: vm.models,
          nameSelector: (model) => model.uiName,
          keySelector: (model) => model.name,
          projectKey: vm.projectKey,
          matchesFilter: (model, filter) => true,
          onAdd: () => openModelCreateDialog(
            context,
            NavigationEntry.function,
            vm.projectKey,
          ),
          onModelTap: (model) {
            context.dispatch(SelectExpressionFunctionAction(model));
            context.go('${NavigationEntry.function.route}/detail');
          },
          onRefresh: () => context.dispatch(RefreshExpressionFunctionAction()),
          hasMore: vm.hasNextPage,
          isLoadingMore: vm.isLoadingMore,
          onLoadMore: vm.hasNextPage && !vm.isLoadingMore
              ? () => context.dispatch(InitExpressionFunctionAction())
              : null,
        );
      },
    );
  }
}

/// A function's card: its name, and its identifier with the parameters it
/// takes, as a formula calls it.
class _FunctionCardContent extends StatelessWidget {
  const _FunctionCardContent({required this.function});

  final ExpressionFunctionModel function;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parameters = function.parameters.map((p) => p.name).join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          function.uiName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${function.name}($parameters)',
          style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
