import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_card.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/feature/expression/expression_value_field.dart';
import 'package:stelaris/feature/expression/expression_variable_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The pause after the last change before the result is asked for again.
const Duration expressionPreviewDebounce = Duration(milliseconds: 400);

/// What a preview asks the backend about: the project, the text evaluated and
/// the variables with the values evaluated with. Two requests must be equal
/// when the backend would answer them the same way, since a new request is
/// only sent for a request that differs.
@immutable
abstract class ExpressionPreviewRequest {
  const ExpressionPreviewRequest();

  String? get projectId;

  /// The text evaluated, such as an expression's formula. Nothing is asked
  /// while it is blank.
  String get formula;

  /// The variables with the values evaluated with.
  List<ExpressionVariable> get variables;

  /// Asks the backend for the result of this request in [projectId].
  Future<ExpressionResult> evaluate(String projectId);

  /// The names of the variables without a value.
  List<String> get missing => [
    for (final variable in variables)
      if (variable.testValue?.trim().isEmpty ?? true) variable.name,
  ];

  /// Whether a value does not fit the type of its variable.
  bool get invalid => variables.any(
    (variable) =>
        !isExpressionValueValid(variable.type, variable.testValue ?? ''),
  );
}

/// [variables] with the values in [overrides], by variable name, in place of
/// their stored test values.
List<ExpressionVariable> withPreviewValues(
  List<ExpressionVariable> variables,
  Map<String, String> overrides,
) {
  if (overrides.isEmpty) return variables;
  return [
    for (final variable in variables)
      if (overrides[variable.name] case final value?)
        variable.copyWith(testValue: value)
      else
        variable,
  ];
}

/// The live result of a [request]: first the value the backend evaluates it
/// to, then the [formula] when there is one, and the variables with their
/// values. The request is sent again once it stops changing for [debounce].
///
/// Nothing is stored here. The values start as the variables' test values and
/// can be changed here to try others: those go to [onOverridesChanged], and
/// the caller puts them into the next request. A variable without a value is
/// not sent: the panel asks for one instead.
class ExpressionPreviewPanel extends StatefulWidget {
  const ExpressionPreviewPanel({
    required this.request,
    required this.variables,
    required this.overrides,
    required this.onOverridesChanged,
    this.debounce = expressionPreviewDebounce,
    this.formula,
    this.variablesTitle,
    this.noVariablesHint,
    super.key,
  });

  /// What is sent: the formula with the values typed in, or else the stored
  /// test values.
  final ExpressionPreviewRequest request;

  /// The variables with their stored test values.
  final List<ExpressionVariable> variables;

  /// The values typed in, by the name of a current variable.
  final Map<String, String> overrides;
  final ValueChanged<Map<String, String>> onOverridesChanged;
  final Duration debounce;

  /// The formula as it is shown below the result, or null to leave it out.
  final Widget? formula;

  /// The heading of the variables, the expression's wording when null.
  final String? variablesTitle;

  /// Shown when there are no variables, the expression's wording when null.
  final String? noVariablesHint;

  @override
  State<ExpressionPreviewPanel> createState() => _ExpressionPreviewPanelState();
}

class _ExpressionPreviewPanelState extends State<ExpressionPreviewPanel> {
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
  void didUpdateWidget(ExpressionPreviewPanel oldWidget) {
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
        request.formula.trim().isEmpty ||
        request.missing.isNotEmpty ||
        request.invalid) {
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
      final result = await request.evaluate(projectId);
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
    final formula = widget.formula;
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
            EditSectionHeading(title: l10n.expression_preview_result_label),
            const SizedBox(height: 8),
            _outcome(context, request),
            if (formula != null) ...[
              const SizedBox(height: 24),
              EditSectionHeading(title: l10n.expression_section_formula),
              const SizedBox(height: 8),
              formula,
            ],
            const SizedBox(height: 24),
            EditSectionHeading(
              title:
                  widget.variablesTitle ??
                  l10n.expression_preview_section_variables,
              trailing: widget.overrides.isEmpty
                  ? null
                  : IconButton(
                      key: const Key('expression_preview_reset'),
                      tooltip: l10n.expression_preview_reset_values,
                      icon: const Icon(Icons.restart_alt, size: 20),
                      onPressed: () => widget.onOverridesChanged(const {}),
                    ),
            ),
            const SizedBox(height: 8),
            if (request.variables.isEmpty)
              Text(
                widget.noVariablesHint ?? l10n.expression_preview_no_variables,
                style: theme.textTheme.bodySmall,
              )
            else
              _VariableInputs(
                variables: widget.variables,
                overrides: widget.overrides,
                onChanged: widget.onOverridesChanged,
              ),
          ],
        ),
      ),
    );
  }

  Widget _outcome(BuildContext context, ExpressionPreviewRequest request) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final errorStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.error,
    );
    if (request.formula.trim().isEmpty) return const SizedBox.shrink();
    if (request.missing.isNotEmpty) {
      return Text(
        l10n.expression_preview_missing_values(request.missing.join(', ')),
        style: theme.textTheme.bodySmall,
      );
    }
    // The field that does not fit says so itself.
    if (request.invalid) return const SizedBox.shrink();
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
      return Text(l10n.expression_preview_error, style: errorStyle);
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

/// One input per variable, labelled with its name and the icon of its type,
/// holding the value the preview evaluates with: the stored test value until
/// another is typed in. A typed value goes to [onChanged] with the others in
/// [overrides], and is marked as not saved. Typing the stored value again
/// takes it out.
class _VariableInputs extends StatefulWidget {
  const _VariableInputs({
    required this.variables,
    required this.overrides,
    required this.onChanged,
  });

  /// The variables with their stored test values.
  final List<ExpressionVariable> variables;
  final Map<String, String> overrides;
  final ValueChanged<Map<String, String>> onChanged;

  @override
  State<_VariableInputs> createState() => _VariableInputsState();
}

class _VariableInputsState extends State<_VariableInputs> {
  final Map<String, TextEditingController> _inputs = {};

  /// Set while the inputs are matched to the values, so their listeners do
  /// not take that for typing.
  bool _syncing = false;

  @override
  void didUpdateWidget(_VariableInputs oldWidget) {
    super.didUpdateWidget(oldWidget);
    final names = {for (final variable in widget.variables) variable.name};
    for (final name in [..._inputs.keys]) {
      if (names.contains(name)) continue;
      // Its field is still attached until this build has replaced it.
      final input = _inputs.remove(name)!;
      WidgetsBinding.instance.addPostFrameCallback((_) => input.dispose());
    }
    // A reset, or a stored test value changed elsewhere, shows here.
    _syncing = true;
    for (final variable in widget.variables) {
      final input = _inputs[variable.name];
      final value = _valueOf(variable);
      if (input != null && input.text != value) input.text = value;
    }
    _syncing = false;
  }

  @override
  void dispose() {
    for (final input in _inputs.values) {
      input.dispose();
    }
    super.dispose();
  }

  String _valueOf(ExpressionVariable variable) =>
      widget.overrides[variable.name] ?? variable.testValue ?? '';

  TextEditingController _inputFor(ExpressionVariable variable) =>
      _inputs.putIfAbsent(variable.name, () {
        final input = TextEditingController(text: _valueOf(variable));
        input.addListener(() => _typed(variable.name, input.text));
        return input;
      });

  void _typed(String name, String text) {
    if (_syncing) return;
    final variable = widget.variables
        .where((variable) => variable.name == name)
        .firstOrNull;
    if (variable == null) return;
    final overrides = widget.overrides;
    final stored = variable.testValue ?? '';
    if (text == (overrides[name] ?? stored)) return;
    widget.onChanged({
      for (final entry in overrides.entries)
        if (entry.key != name) entry.key: entry.value,
      if (text != stored) name: text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final variable in widget.variables)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ExpressionValueField(
              // A boolean is picked from a menu that shows its first value
              // only, so a changed value builds a new one.
              key: ValueKey((
                variable.name,
                variable.type,
                variable.type == ExpressionValueType.boolean
                    ? _valueOf(variable)
                    : null,
              )),
              controller: _inputFor(variable),
              type: variable.type,
              decoration: InputDecoration(
                isDense: true,
                labelText: variable.name,
                hintText: l10n.expression_variable_no_test_value,
                helperText: widget.overrides.containsKey(variable.name)
                    ? l10n.expression_preview_value_not_saved
                    : null,
                prefixIcon: Tooltip(
                  message: expressionVariableTypeLabel(l10n, variable.type),
                  child: Icon(
                    expressionVariableTypeIcon(variable.type),
                    size: 18,
                    color: colors.tertiary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
