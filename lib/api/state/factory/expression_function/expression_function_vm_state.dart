import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/model/expression_function_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/expression_function/expression_function_page.dart';

/// The list page's view of the project's functions, with their paging state.
class ExpressionFunctionVmFactory
    extends
        VmFactory<
          AppState,
          ExpressionFunctionPage,
          ExpressionFunctionViewModel
        > {
  ExpressionFunctionVmFactory();

  @override
  ExpressionFunctionViewModel fromStore() => ExpressionFunctionViewModel(
    models: state.expressionFunctions.items,
    hasNextPage: state.expressionFunctions.hasNextPage,
    isLoadingMore: state.isLoadingMoreExpressionFunctions,
    projectKey: state.selectedProject!.key,
  );
}

class ExpressionFunctionViewModel extends Vm {
  ExpressionFunctionViewModel({
    required this.models,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.projectKey,
  }) : super(equals: [models, hasNextPage, isLoadingMore, projectKey]);

  final List<ExpressionFunctionModel> models;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String projectKey;
}
