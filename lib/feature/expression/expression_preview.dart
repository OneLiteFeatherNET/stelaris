import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/expression/selected_expression_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_card.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/feature/expression/expression_math_view.dart';
import 'package:stelaris/feature/expression/expression_tex.dart';
import 'package:stelaris/feature/expression/expression_variable_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The pause after the last change before the result is asked for again.
const Duration expressionPreviewDebounce = Duration(milliseconds: 400);

/// The live result of the expression, as the formula is typed: first the value
/// the backend evaluates it to, then the formula when [showFormula], and the
/// variables with their test values. Shown beside the General and Variables
/// tabs on a wide screen, and as a bottom sheet on a narrow one.
///
/// Nothing is stored here. The values are the variables' test values, which
/// the Variables tab edits. A variable without one is not sent: the preview
/// asks for the values to be given instead.
class ExpressionPreview extends StatelessWidget {
  const ExpressionPreview({
    this.debounce = expressionPreviewDebounce,
    this.showFormula = true,
    super.key,
  });

  /// Whether the formula is shown too. Off beside a page that shows it
  /// already.
  final bool showFormula;

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
          showFormula: showFormula,
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
    required this.showFormula,
    this.catalog,
  });

  final _PreviewRequest request;
  final Duration debounce;
  final bool showFormula;

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

  /// The formula last typeset by [_tex], with the catalog it was named by.
  ({String formula, ExpressionCatalog? catalog, String? tex})? _texMemo;

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
    // The last result stays, dimmed, until the new one is in, so the panel
    // does not jump on every key.
    setState(() {
      _running = true;
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
        _result = null;
        _rejection = problem;
      });
    } catch (_) {
      if (!mounted || evaluation != _evaluation) return;
      setState(() {
        _running = false;
        _result = null;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final request = widget.request;
    final colors = theme.colorScheme;
    // The same surface as the section cards beside it; the sections are set
    // apart by space, not by lines.
    return EditSectionCard(
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
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.expression_preview_title,
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            EditSectionHeading(title: l10n.expression_test_result_label),
            const SizedBox(height: 8),
            _outcome(context, request),
            if (widget.showFormula) ...[
              const SizedBox(height: 24),
              EditSectionHeading(title: l10n.expression_section_formula),
              const SizedBox(height: 8),
              if (request.expression.trim().isEmpty)
                Text(
                  l10n.expression_test_empty_hint,
                  style: theme.textTheme.bodySmall,
                )
              else
                _formula(request.expression, _tex(request.expression)),
            ],
            const SizedBox(height: 24),
            EditSectionHeading(title: l10n.expression_test_section_variables),
            const SizedBox(height: 8),
            if (request.variables.isEmpty)
              Text(
                l10n.expression_test_no_variables,
                style: theme.textTheme.bodySmall,
              )
            else
              _VariableList(variables: request.variables),
          ],
        ),
      ),
    );
  }

  /// The LaTeX of [formula], null when it does not convert. The last one is
  /// kept while the formula and the catalog stay the same, since the preview
  /// rebuilds whenever an evaluation changes.
  String? _tex(String formula) {
    final catalog = widget.catalog;
    final memo = _texMemo;
    if (memo != null &&
        memo.formula == formula &&
        identical(memo.catalog, catalog)) {
      return memo.tex;
    }
    final tex = expressionToTex(
      formula,
      functionNames: catalogFunctionNames(catalog),
    );
    _texMemo = (formula: formula, catalog: catalog, tex: tex);
    return tex;
  }

  Widget _formula(String formula, String? tex) =>
      ExpressionMathView(formula: formula, tex: tex, fontSize: 22);

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
    final result = _result;
    if (_running && result == null) {
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
    if (result == null) return const SizedBox.shrink();
    return _ResultTile(result: result, pending: _running);
  }
}

/// The value of the formula on a colored surface of its own, rounded to fit
/// one line, with its type below. The full value is in the tooltip and can be
/// copied. While [pending] a new result is on its way, and this one is dimmed.
class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result, required this.pending});

  final ExpressionResult result;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final shown = formatExpressionResult(result.value);
    return AnimatedOpacity(
      key: const ValueKey('expression_preview_result'),
      duration: const Duration(milliseconds: 150),
      opacity: pending ? 0.5 : 1,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: colors.primaryContainer,
          shape: AppShapes.rounded(AppShapes.small),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: result.value,
                      child: Text(
                        shown,
                        key: const ValueKey('expression_preview_value'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: 'monospace',
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expressionResultTypeLabel(l10n, result.type),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.expression_preview_copy,
                color: colors.onPrimaryContainer,
                icon: const Icon(Icons.copy_outlined, size: 20),
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: result.value)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// [value] as the preview shows it: a decimal number rounded to at most six
/// places, without trailing zeros, anything else as it is.
String formatExpressionResult(String value) {
  final number = double.tryParse(value.trim());
  final decimals = value.contains('.') ? value.split('.').last.length : 0;
  if (number == null || !number.isFinite || decimals <= 6) return value;
  final fixed = number.toStringAsFixed(6);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// The backend's result [type] in words. A type the app does not know is
/// shown as the backend names it.
String expressionResultTypeLabel(AppLocalizations l10n, String type) =>
    switch (type.toUpperCase()) {
      'NUMBER' || 'NUMERIC' => l10n.expression_variable_type_number,
      'BOOLEAN' => l10n.expression_variable_type_boolean,
      'STRING' => l10n.expression_variable_type_string,
      _ => type,
    };

/// The variables as a compact list, one row each: the type icon and the name
/// in the color of the variable chips, and the test value at the end. A
/// variable without a test value says so in place of the value.
class _VariableList extends StatelessWidget {
  const _VariableList({required this.variables});

  final List<ExpressionVariable> variables;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const monospace = TextStyle(fontFamily: 'monospace');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final variable in variables)
          Tooltip(
            message: expressionVariableTypeLabel(l10n, variable.type),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    expressionVariableTypeIcon(variable.type),
                    size: 18,
                    color: colors.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      variable.name,
                      overflow: TextOverflow.ellipsis,
                      style: monospace.copyWith(
                        color: colors.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (variable.testValue?.trim().isEmpty ?? true)
                    Text(
                      l10n.expression_variable_no_test_value,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    )
                  else
                    Flexible(
                      child: SelectableText(
                        variable.testValue!,
                        maxLines: 1,
                        style: monospace,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
