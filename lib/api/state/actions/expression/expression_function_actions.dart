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

final _modelList = ModelList<ExpressionFunctionModel>(
  of: (state) => state.expressionFunctions,
  withList: (state, list) => state.copyWith(expressionFunctions: list),
  api: () => ApiService().expressionFunctionApi,
);

/// Refetches the first page of the functions and replaces what was loaded.
class RefreshExpressionFunctionAction
    extends RefreshListAction<ExpressionFunctionModel> {
  RefreshExpressionFunctionAction() : super(_modelList);
}

/// Loads the first page of the functions when none is loaded.
class InitExpressionFunctionAction
    extends InitListAction<ExpressionFunctionModel> {
  InitExpressionFunctionAction()
    : super(_modelList);
}

/// Appends the next page of the functions. While it loads,
/// `isWaiting(LoadMoreExpressionFunctionsAction)` is true.
class LoadMoreExpressionFunctionsAction
    extends LoadMoreListAction<ExpressionFunctionModel> {
  LoadMoreExpressionFunctionsAction() : super(_modelList);
}

class ExpressionFunctionRemoveAction extends ReduxAction<AppState> {
  final ExpressionFunctionModel model;

  ExpressionFunctionRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().expressionFunctionApi.remove(model);
    // The selection stays while the detail page is still mounted during its
    // exit transition; its onDispose clears it.
    dispatch(ReloadExpressionCatalogAction());
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
    dispatch(ReloadExpressionCatalogAction());
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
  AppState? reduce() => state.copyWith(
    selectedExpressionFunction: newEntry,
    expressionFunctionProblem: null,
    unsavedChanges: NavigationEntry.function,
  );
}

/// Saves [notes] as [model]'s comment, from the overview card's menu. An
/// open function only takes the new comment, so its unsaved edits stay.
class ExpressionFunctionNotesUpdateAction extends ReduxAction<AppState>
    with NonReentrant {
  final ExpressionFunctionModel model;
  final String? notes;

  ExpressionFunctionNotesUpdateAction(this.model, this.notes);

  @override
  Future<AppState?> reduce() async {
    final ExpressionFunctionModel response = await ApiService()
        .expressionFunctionApi
        .update(model.copyWith(comment: notes));
    final selected = state.selectedExpressionFunction;
    return state.copyWith(
      expressionFunctions: state.expressionFunctions.replacingWhere(
        (item) => item.id == response.id,
        response,
      ),
      selectedExpressionFunction: selected?.id == response.id
          ? selected!.copyWith(comment: response.comment)
          : selected,
    );
  }
}

/// Saves the selected function. A rejection (HTTP 400) is kept in the state,
/// so the fields it names can show it, and is thrown on as a [ProblemDetail]
/// for the save's own message.
///
/// The catalog is loaded again only when the save changed the function's
/// signature, or when no stored copy of it is loaded to compare with.
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
    final stored = state.expressionFunctions.items
        .where((element) => element.id == selected.id)
        .firstOrNull;
    if (stored == null || _changesCatalog(stored, response)) {
      dispatch(ReloadExpressionCatalogAction());
    }
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

/// Whether [saved] shows another entry in the catalog than [before]: the
/// catalog lists a function by its name, kind, return type and parameters, so
/// a changed body or comment leaves it as it is. A parameter's test value is
/// not part of its signature.
bool _changesCatalog(
  ExpressionFunctionModel before,
  ExpressionFunctionModel saved,
) {
  if (before.name != saved.name ||
      before.kind != saved.kind ||
      before.returnType != saved.returnType ||
      before.parameters.length != saved.parameters.length) {
    return true;
  }
  for (var i = 0; i < saved.parameters.length; i++) {
    final a = before.parameters[i];
    final b = saved.parameters[i];
    if (a.name != b.name || a.type != b.type) return true;
  }
  return false;
}

class _SetExpressionFunctionProblem extends ReduxAction<AppState> {
  final ProblemDetail problem;

  _SetExpressionFunctionProblem(this.problem);

  @override
  AppState reduce() => state.copyWith(expressionFunctionProblem: problem);
}
