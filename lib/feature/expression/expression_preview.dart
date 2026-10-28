import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression/selected_expression_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/feature/expression/expression_math_view.dart';
import 'package:stelaris/feature/expression/expression_tex.dart';
import 'package:stelaris/feature/expression/expression_variable_dialog.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The pause after the last change before the result is asked for again.
const Duration expressionPreviewDebounce = Duration(milliseconds: 400);

/// The live result of the expression, as the formula is typed: the formula,
/// its variables with their test values, and the value the backend evaluates
/// it to. Shown beside the General and Variables tabs on a wide screen, and
/// as a bottom sheet on a narrow one.
///
/// Nothing is stored here. The values are the variables' test values, which
/// the Variables tab edits. A variable without one is not sent: the preview
/// asks for the values to be given instead.
class ExpressionPreview extends StatelessWidget {
  const ExpressionPreview({
    this.debounce = expressionPreviewDebounce,
    super.key,
  });

  /// The pause after a change before the backend is asked, see
  /// [expressionPreviewDebounce].
  final Duration debounce;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedExpressionView>(
      vm: () => SelectedExpressionState(),
      builder: (context, vm) => StoreConnector<AppState, ExpressionCatalog?>(
        converter: (store) => store.state.expressionCatalog,
        builder: (context, catalog) => _ExpressionPreviewBody(
          request: _PreviewRequest(
            projectId: vm.projectId,
            expression: vm.selected.expression,
            variables: vm.selected.variables,
          ),
          debounce: debounce,
          catalog: catalog,
        ),
      ),
    );
  }
}

/// What the preview asks the backend about: the project, the formula and the
/// variables with their test values. Two requests are equal when the backend
/// would answer them the same way.
@immutable
class _PreviewRequest {
  const _PreviewRequest({
    required this.projectId,
    required this.expression,
    required this.variables,
  });

  final String? projectId;
  final String expression;
  final List<ExpressionVariable> variables;

  /// The names of the variables without a test value.
  List<String> get missing => [
    for (final variable in variables)
      if (variable.testValue?.trim().isEmpty ?? true) variable.name,
  ];

  @override
  bool operator ==(Object other) =>
      other is _PreviewRequest &&
      other.projectId == projectId &&
      other.expression == expression &&
      listEquals(other.variables, variables);

  @override
  int get hashCode =>
      Object.hash(projectId, expression, Object.hashAll(variables));
}

class _ExpressionPreviewBody extends StatefulWidget {
  const _ExpressionPreviewBody({
    required this.request,
    required this.debounce,
    this.catalog,
  });

  final _PreviewRequest request;
  final Duration debounce;

  /// Names the functions the formula is typeset with. Not part of the request:
  /// the backend's answer does not depend on it.
  final ExpressionCatalog? catalog;

  @override
  State<_ExpressionPreviewBody> createState() => _ExpressionPreviewBodyState();
}

class _ExpressionPreviewBodyState extends State<_ExpressionPreviewBody> {
  Timer? _timer;

  /// Counts the evaluations started. An answer to an older request is dropped.
  int _evaluation = 0;
  bool _running = false;
  ExpressionResult? _result;

  /// The backend rejected the formula or a variable, with its violations.
  ProblemDetail? _rejection;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(_ExpressionPreviewBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request != widget.request) _schedule();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Asks the backend once the requests stop changing for [widget.debounce].
  /// Only the state fields change here, not the widget: this runs from
  /// initState and didUpdateWidget, where the tree is being built.
  void _schedule() {
    _timer?.cancel();
    // An answer that is still on its way belongs to a request now replaced.
    _evaluation++;
    _running = false;
    _timer = Timer(widget.debounce, _evaluate);
  }

  Future<void> _evaluate() async {
    final request = widget.request;
    final projectId = request.projectId;
    if (projectId == null ||
        request.expression.trim().isEmpty ||
        request.missing.isNotEmpty) {
      return;
    }
    final evaluation = ++_evaluation;
    setState(() {
      _running = true;
      _result = null;
      _rejection = null;
      _failed = false;
    });
    try {
      final result = await ApiService().expressionApi.evaluate(
        projectId,
        request.expression,
        request.variables,
      );
      if (!mounted || evaluation != _evaluation) return;
      setState(() {
        _running = false;
        _result = result;
      });
    } on ProblemDetail catch (problem) {
      if (!mounted || evaluation != _evaluation) return;
      setState(() {
        _running = false;
        _rejection = problem;
      });
    } catch (_) {
      if (!mounted || evaluation != _evaluation) return;
      setState(() {
        _running = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final request = widget.request;
    // The panel is its own surface, one step above the section cards beside
    // it. Its sections are separated by dividers.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppShapes.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          key: const Key('expression_preview'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.preview_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.expression_preview_title,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              const Divider(height: 32),
              EditSectionHeading(title: l10n.expression_section_formula),
              const SizedBox(height: 8),
              if (request.expression.trim().isEmpty)
                Text(
                  l10n.expression_test_empty_hint,
                  style: theme.textTheme.bodySmall,
                )
              else ...[
                _formula(request.expression),
                // The raw text is only shown under a typeset formula: without one,
                // the math view already shows it.
                if (_tex(request.expression) != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    request.expression,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
              const Divider(height: 32),
              EditSectionHeading(title: l10n.expression_test_section_variables),
              const SizedBox(height: 8),
              if (request.variables.isEmpty)
                Text(l10n.expression_test_no_variables)
              else
                _VariableTable(variables: request.variables),
              const Divider(height: 32),
              EditSectionHeading(title: l10n.expression_test_result_label),
              const SizedBox(height: 8),
              _outcome(context, request),
            ],
          ),
        ),
      ),
    );
  }

  /// The LaTeX of [formula], null when it does not convert.
  String? _tex(String formula) => expressionToTex(
    formula,
    functionNames: catalogFunctionNames(widget.catalog),
  );

  Widget _formula(String formula) =>
      ExpressionMathView(formula: formula, tex: _tex(formula), fontSize: 22);

  Widget _outcome(BuildContext context, _PreviewRequest request) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final errorStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.error,
    );
    if (request.expression.trim().isEmpty) return const SizedBox.shrink();
    if (request.missing.isNotEmpty) {
      return Text(
        l10n.expression_preview_missing_values(request.missing.join(', ')),
        style: theme.textTheme.bodySmall,
      );
    }
    if (request.projectId == null) {
      return Text(
        l10n.expression_preview_no_project,
        style: theme.textTheme.bodySmall,
      );
    }
    if (_running) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failed) {
      return Text(l10n.expression_test_error, style: errorStyle);
    }
    final rejection = _rejection;
    if (rejection != null) {
      if (rejection.errors.isEmpty) {
        return Text(rejection.displayMessage, style: errorStyle);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final error in rejection.errors)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(error.message, style: errorStyle),
            ),
        ],
      );
    }
    final result = _result;
    if (result == null) return const SizedBox.shrink();
    return Row(
      children: [
        Flexible(
          child: SelectableText(
            result.value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Chip(label: Text(result.type)),
      ],
    );
  }
}

/// The variables as a table: name, type and test value. A variable without a
/// test value says so in place of the value.
class _VariableTable extends StatelessWidget {
  const _VariableTable({required this.variables});

  final List<ExpressionVariable> variables;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppShapes.small),
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(),
          1: IntrinsicColumnWidth(),
          2: FlexColumnWidth(),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
            ),
            children: [
              _cell(
                Text(l10n.expression_preview_column_name, style: headerStyle),
              ),
              _cell(
                Text(l10n.expression_variable_type_label, style: headerStyle),
              ),
              _cell(
                Text(
                  l10n.expression_variable_test_value_label,
                  style: headerStyle,
                ),
              ),
            ],
          ),
          for (final variable in variables)
            TableRow(
              children: [
                _cell(
                  Text(
                    variable.name,
                    style: const TextStyle(fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _cell(Text(expressionVariableTypeLabel(l10n, variable.type))),
                _cell(
                  variable.testValue?.trim().isEmpty ?? true
                      ? Text(
                          l10n.expression_variable_no_test_value,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : SelectableText(
                          variable.testValue!,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static Widget _cell(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    child: child,
  );
}
