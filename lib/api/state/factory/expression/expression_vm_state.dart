import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/expression/expression_page.dart';
import 'package:stelaris_models/stelaris_models.dart';

class ExpressionVmFactory
    extends VmFactory<AppState, ExpressionPage, ExpressionViewModel> {
  ExpressionVmFactory();

  @override
  ExpressionViewModel fromStore() => ExpressionViewModel(
    models: state.expressions.items,
    hasNextPage: state.expressions.hasNextPage,
    isLoadingMore: state.isLoadingMoreExpressions,
    projectKey: state.selectedProject!.key,
  );
}

class ExpressionViewModel extends Vm {
  ExpressionViewModel({
    required this.models,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.projectKey,
  }) : super(equals: [models, hasNextPage, isLoadingMore, projectKey]);

  final List<ExpressionModel> models;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String projectKey;
}
