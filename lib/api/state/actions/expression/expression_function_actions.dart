import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/actions/paginated_loading.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Selects [model] for its detail page. Its unsaved flag and the rejection of
/// an earlier save go with the previous selection.
class SelectExpressionFunctionAction extends ReduxAction<AppState> {
  final ExpressionFunctionModel model;

  SelectExpressionFunctionAction(this.model);

  @override
  AppState reduce() => state
      .copyWith(
        selectedExpressionFunction: model,
        expressionFunctionProblem: null,
      )
      .clearUnsavedChanges(NavigationEntry.function);
}

class RemoveSelectedExpressionFunction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    if (state.selectedExpressionFunction == null) return null;
    return state
        .copyWith(
          selectedExpressionFunction: null,
          expressionFunctionProblem: null,
        )
        .clearUnsavedChanges(NavigationEntry.function);
  }
}

/// Always refetches page 1 and replaces the current list, regardless of how
/// many pages were already loaded. Used by the grid's manual refresh button.
class RefreshExpressionFunctionAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    return state.copyWith(expressionFunctions: await _firstPage(state));
  }
}

/// Loads the next page of the functions, or the first page when none is
/// loaded yet.
class InitExpressionFunctionAction extends ReduxAction<AppState> {
  InitExpressionFunctionAction();

  @override
  Future<AppState?> reduce() async {
    final hasExisting = state.expressionFunctions.items.isNotEmpty;
    final canLoadMore = state.expressionFunctions.hasNextPage;

    if (hasExisting && !canLoadMore) return null;

    if (hasExisting && canLoadMore) {
      if (state.isLoadingMoreExpressionFunctions) return null;
      dispatchSync(_SetLoadMoreExpressionFunctions(true));
      try {
        final current = state.expressionFunctions;
        final next = await ApiService().expressionFunctionApi.getPage(
          page: current.currentPage + 1,
          size: current.requestSize,
          projectId: state.selectedProject?.id,
        );

        // A project switch or refresh replaced the list while the page
        // loaded, so the page no longer continues it.
        if (!identical(state.expressionFunctions, current)) return null;

        return state.copyWith(
          expressionFunctions: current.append(next),
          isLoadingMoreExpressionFunctions: false,
        );
      } finally {
        dispatchSync(_SetLoadMoreExpressionFunctions(false));
      }
    } else {
      return state.copyWith(expressionFunctions: await _firstPage(state));
    }
  }
}

class ExpressionFunctionRemoveAction extends ReduxAction<AppState> {
  final ExpressionFunctionModel model;

  ExpressionFunctionRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().expressionFunctionApi.remove(model);
    // The selection stays while the detail page is still mounted during its
    // exit transition; its onDispose clears it.
    await dispatchAndWait(ReloadExpressionCatalogAction());
    return state.copyWith(
      expressionFunctions: state.expressionFunctions.removingWhere(
        (element) => element.id == model.id,
      ),
    );
  }
}

class ExpressionFunctionAddAction extends ReduxAction<AppState>
    with NonReentrant {
  final ExpressionFunctionModel _model;

  ExpressionFunctionAddAction(this._model);

  @override
  Future<AppState?> reduce() async {
    final toAdd = _model.projectId == null && state.selectedProject != null
        ? _model.copyWith(projectId: state.selectedProject!.id)
        : _model;
    final ExpressionFunctionModel databaseModel = await ApiService()
        .expressionFunctionApi
        .add(toAdd);
    await dispatchAndWait(ReloadExpressionCatalogAction());
    return state.copyWith(
      expressionFunctions: state.expressionFunctions.adding(databaseModel),
      selectedExpressionFunction: databaseModel,
      expressionFunctionProblem: null,
    );
  }
}

/// Puts [newEntry] into the selection and marks the function unsaved. A
/// rejection of an earlier save is dropped: the field it named may have
/// changed.
class UpdateExpressionFunctionAction extends ReduxAction<AppState> {
  final ExpressionFunctionModel newEntry;

  UpdateExpressionFunctionAction(this.newEntry);

  @override
  Future<AppState?> reduce() async => state.copyWith(
    selectedExpressionFunction: newEntry,
    expressionFunctionProblem: null,
    unsavedChanges: NavigationEntry.function,
  );
}

/// Saves the selected function. A rejection (HTTP 400) is kept in the state,
/// so the fields it names can show it, and is thrown on as a [ProblemDetail]
/// for the save's own message.
class ExpressionFunctionDatabaseUpdate extends ReduxAction<AppState>
    with Throttle {
  ExpressionFunctionDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedExpressionFunction == null) return null;
    final ExpressionFunctionModel selected = state.selectedExpressionFunction!;
    final ExpressionFunctionModel response;
    try {
      response = await ApiService().expressionFunctionApi.update(selected);
    } on DioException catch (error) {
      if (error.response?.statusCode != 400) rethrow;
      final problem = ProblemDetail.fromDioException(error);
      dispatchSync(_SetExpressionFunctionProblem(problem));
      throw problem;
    }
    await dispatchAndWait(ReloadExpressionCatalogAction());
    return state
        .copyWith(
          expressionFunctions: state.expressionFunctions.replacingWhere(
            (element) => element.id == selected.id,
            response,
          ),
          selectedExpressionFunction: response,
          expressionFunctionProblem: null,
        )
        .clearUnsavedChanges(NavigationEntry.function);
  }
}

/// Page 1 of the functions of the open project, in the size of the loaded
/// pages.
Future<PaginatedResult<ExpressionFunctionModel>> _firstPage(AppState state) =>
    ApiService().expressionFunctionApi.getPage(
      page: 1,
      size: state.expressionFunctions.requestSize,
      projectId: state.selectedProject?.id,
    );

class _SetLoadMoreExpressionFunctions extends ReduxAction<AppState> {
  final bool value;

  _SetLoadMoreExpressionFunctions(this.value);

  @override
  AppState reduce() => state.copyWith(isLoadingMoreExpressionFunctions: value);
}

class _SetExpressionFunctionProblem extends ReduxAction<AppState> {
  final ProblemDetail problem;

  _SetExpressionFunctionProblem(this.problem);

  @override
  AppState reduce() => state.copyWith(expressionFunctionProblem: problem);
}
