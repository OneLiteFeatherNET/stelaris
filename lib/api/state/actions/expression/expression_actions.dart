import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/model/expression_validation_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/expression_validation_state.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/api/state/actions/paginated_loading.dart';
import 'package:stelaris_models/stelaris_models.dart';

class SelectExpressionAction extends ReduxAction<AppState> {
  final ExpressionModel model;

  SelectExpressionAction(this.model);

  @override
  AppState reduce() => state
      .copyWith(selectedExpression: model, expressionValidation: null)
      .clearUnsavedChanges(NavigationEntry.expression);
}

class RemoveSelectedExpression extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    if (state.selectedExpression == null) return null;
    return state
        .copyWith(selectedExpression: null, expressionValidation: null)
        .clearUnsavedChanges(NavigationEntry.expression);
  }
}

/// Always refetches page 1 and replaces the current list, regardless of
/// how many pages were already loaded - used by the grid's manual refresh
/// button, as opposed to [InitExpressionAction] which only ever loads the
/// next page or the very first page.
class RefreshExpressionAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    return state.copyWith(expressions: await _firstPage(state));
  }
}

class InitExpressionAction extends ReduxAction<AppState> {
  InitExpressionAction();

  @override
  Future<AppState?> reduce() async {
    // If we already have items and more pages, treat this as load-more.
    final hasExisting = state.expressions.items.isNotEmpty;
    final canLoadMore = state.expressions.hasNextPage;

    if (hasExisting && !canLoadMore) return null;

    if (hasExisting && canLoadMore) {
      if (state.isLoadingMoreExpressions) return null;
      dispatchSync(_SetLoadMoreExpressions(true));
      try {
        final current = state.expressions;
        final next = await ApiService().expressionApi.getPage(
          page: current.currentPage + 1,
          size: current.requestSize,
          projectId: state.selectedProject?.id,
        );

        // A project switch or refresh replaced the list while the page
        // loaded, so the page no longer continues it.
        if (!identical(state.expressions, current)) return null;

        final updated = current.append(next);
        // The flag is cleared here as well: this state is applied after the
        // `finally` below and would otherwise set the flag back to true.
        return state.copyWith(
          expressions: updated,
          isLoadingMoreExpressions: false,
        );
      } finally {
        dispatchSync(_SetLoadMoreExpressions(false));
      }
    } else {
      // Initial load (or refresh)
      return state.copyWith(expressions: await _firstPage(state));
    }
  }
}

class ExpressionRemoveAction extends ReduxAction<AppState> {
  final ExpressionModel model;

  ExpressionRemoveAction(this.model);

  @override
  Future<AppState?> reduce() async {
    await ApiService().expressionApi.remove(model);
    // The selection stays: when deleting from the detail page, that page is
    // still mounted during its exit transition and reads it. The page's
    // onDispose clears it.
    return state.copyWith(
      expressions: state.expressions.removingWhere(
        (element) => element.id == model.id,
      ),
    );
  }
}

class ExpressionAddAction extends ReduxAction<AppState> with NonReentrant {
  final ExpressionModel _model;

  ExpressionAddAction(this._model);

  @override
  Future<AppState?> reduce() async {
    final toAdd = _model.projectId == null && state.selectedProject != null
        ? _model.copyWith(projectId: state.selectedProject!.id)
        : _model;
    final ExpressionModel databaseModel = await ApiService().expressionApi.add(
      toAdd,
    );
    return state.copyWith(
      expressions: state.expressions.adding(databaseModel),
      selectedExpression: databaseModel,
      expressionValidation: null,
    );
  }
}

class UpdateExpressionAction extends ReduxAction<AppState> {
  final ExpressionModel newEntry;

  UpdateExpressionAction(this.newEntry);

  @override
  Future<AppState?> reduce() async => state.copyWith(
    selectedExpression: newEntry,
    unsavedChanges: NavigationEntry.expression,
  );
}

class ExpressionDatabaseUpdate extends ReduxAction<AppState> with Throttle {
  ExpressionDatabaseUpdate();

  @override
  Future<AppState?> reduce() async {
    if (state.selectedExpression == null) return null;
    final ExpressionModel selected = state.selectedExpression!;
    final ExpressionModel response = await ApiService().expressionApi.update(
      selected,
    );
    return state
        .copyWith(
          expressions: state.expressions.replacingWhere(
            (element) => element.id == selected.id,
            response,
          ),
          selectedExpression: response,
        )
        .clearUnsavedChanges(NavigationEntry.expression);
  }
}

/// Saves new [notes] for [model] straight from the overview, without going
/// through the selection and its unsaved-changes flow. The list entry is
/// replaced with the server's response. A selection of the same expression
/// only gets the new notes - its other fields may hold unsaved edits, and a
/// later Save must not send the old notes back.
class ExpressionNotesUpdateAction extends ReduxAction<AppState>
    with NonReentrant {
  final ExpressionModel model;
  final String? notes;

  ExpressionNotesUpdateAction(this.model, this.notes);

  @override
  Future<AppState?> reduce() async {
    final ExpressionModel response = await ApiService().expressionApi.update(
      model.copyWith(comment: notes),
    );
    final selected = state.selectedExpression;
    return state.copyWith(
      expressions: state.expressions.replacingWhere(
        (item) => item.id == response.id,
        response,
      ),
      selectedExpression: selected?.id == response.id
          ? selected!.copyWith(comment: response.comment)
          : selected,
    );
  }
}

/// Asks the backend whether the selected formula [expression] parses and which
/// of the declared [variables] (their names) it reads. Typing dispatches it
/// on every change, so [Debounce] keeps only the last dispatch of a burst.
///
/// The answer is stored only while the selection still has this text and these
/// variables; an answer that arrives after either changed is dropped. A failed
/// request clears the check without a message: the editor just shows no check.
/// Nothing is asked without a selected project, as the endpoint is project
/// scoped.
class ValidateExpressionAction extends ReduxAction<AppState> with Debounce {
  ValidateExpressionAction(
    this.expression,
    this.variables, {
    this.debounceDelay = const Duration(milliseconds: 400),
  });

  final String expression;
  final List<String> variables;

  /// The pause in typing before the check is asked. Tests pass [Duration.zero]
  /// when the debounce itself is not what they check.
  final Duration debounceDelay;

  @override
  int get debounce => debounceDelay.inMilliseconds;

  /// Whether the selection still has the text and variables this asks about.
  bool get _current {
    final selected = state.selectedExpression;
    return selected != null &&
        selected.expression == expression &&
        listEquals(variableNames(selected), variables);
  }

  @override
  Future<AppState?> reduce() async {
    final projectId = state.selectedProject?.id;
    if (projectId == null || !_current) return null;
    final ExpressionValidation validation;
    try {
      validation = await ApiService().expressionApi.validate(
        projectId,
        expression,
        variables,
      );
    } catch (_) {
      if (!_current || state.expressionValidation == null) return null;
      return state.copyWith(expressionValidation: null);
    }
    if (!_current) return null;
    return state.copyWith(
      expressionValidation: ExpressionValidationState(
        expression: expression,
        variables: variables,
        validation: validation,
      ),
    );
  }
}

/// Loads the EvalEx catalog once. Dispatched when an expression opens; a
/// catalog already loaded is kept and nothing is requested again. A failure
/// is logged and leaves the catalog null, so the formula editor simply offers
/// no functions or constants, without an error.
class LoadExpressionCatalogAction extends ReduxAction<AppState>
    with NonReentrant {
  @override
  Future<AppState?> reduce() async {
    if (state.expressionCatalog != null) return null;
    try {
      final catalog = await ApiService().expressionApi.catalog();
      return state.copyWith(expressionCatalog: catalog);
    } catch (error) {
      debugPrint('Error loading the expression catalog: $error');
      return null;
    }
  }
}

/// Internal action to manage the loading state for expression pagination.
class _SetLoadMoreExpressions extends ReduxAction<AppState> {
  final bool value;

  _SetLoadMoreExpressions(this.value);

  @override
  AppState reduce() => state.copyWith(isLoadingMoreExpressions: value);
}

/// Page 1 of the expressions of the open project, in the size of the loaded
/// pages.
Future<PaginatedResult<ExpressionModel>> _firstPage(AppState state) =>
    ApiService().expressionApi.getPage(
      page: 1,
      size: state.expressions.requestSize,
      projectId: state.selectedProject?.id,
    );
