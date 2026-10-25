import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/feature/expression/expression_completion.dart';
import 'package:stelaris/feature/expression/expression_variable_dialog.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The formula as a large multi-line field. Variables of the expression are
/// suggested while an identifier is typed, and listed as chips to insert.
/// [onChanged] gets every new text; the field keeps its own controller, so
/// typing does not move the caret when the store rebuilds.
class ExpressionFormulaField extends StatefulWidget {
  const ExpressionFormulaField({
    required this.expression,
    required this.onChanged,
    super.key,
  });

  final ExpressionModel expression;
  final ValueChanged<String> onChanged;

  @override
  State<ExpressionFormulaField> createState() => _ExpressionFormulaFieldState();
}

class _ExpressionFormulaFieldState extends State<ExpressionFormulaField> {
  static const int _minLines = 8;
  static const double _suggestionsHeight = 200;

  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  /// The highlighted suggestion, moved with the arrow keys.
  int _highlight = 0;

  /// Set by Escape, cleared when the text changes again.
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.expression.expression)
      ..addListener(_onControllerChanged);
    // The focus node handles keys before the text field's own shortcuts do,
    // so Enter, Tab and the arrows can be taken while suggestions are open.
    _focusNode = FocusNode(onKeyEvent: _handleKey)..addListener(_refresh);
  }

  @override
  void didUpdateWidget(ExpressionFormulaField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Another expression was selected: show its formula. Otherwise the
    // controller keeps the text the user is editing.
    if (oldWidget.expression.id != widget.expression.id) {
      _controller.value = TextEditingValue(text: widget.expression.expression);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _onControllerChanged() {
    _highlight = 0;
    _dismissed = false;
    _refresh();
  }

  /// The variables to suggest for the identifier before the caret, empty when
  /// the field is not focused, nothing is typed or Escape closed the list.
  List<ExpressionVariable> _suggestions() {
    if (!_focusNode.hasFocus || _dismissed) return const [];
    final value = _controller.value;
    if (!value.selection.isCollapsed) return const [];
    final prefix = identifierPrefixAt(value.text, value.selection.baseOffset);
    if (prefix == null) return const [];
    return variableSuggestions(widget.expression.variables, prefix.text);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final matches = _suggestions();
    if (matches.isEmpty) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      setState(() => _highlight = (_index(matches) + 1) % matches.length);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      setState(
        () => _highlight =
            (_index(matches) - 1 + matches.length) % matches.length,
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.tab) {
      _accept(matches[_index(matches)]);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      setState(() => _dismissed = true);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// The highlight, kept inside [matches] when the list has shrunk.
  int _index(List<ExpressionVariable> matches) =>
      _highlight < matches.length ? _highlight : 0;

  /// Completes the identifier before the caret to [variable].
  void _accept(ExpressionVariable variable) {
    final value = _controller.value;
    final prefix = identifierPrefixAt(value.text, value.selection.baseOffset);
    if (prefix == null) return;
    _apply(
      completeVariable(
        value.text,
        prefix,
        value.selection.baseOffset,
        variable.name,
      ),
    );
  }

  /// Inserts [name] in place of the selection, or at the caret when nothing
  /// is selected.
  void _insert(String name) {
    final value = _controller.value;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;
    _apply(replaceFormulaRange(value.text, start, end, name));
  }

  void _apply(FormulaEdit edit) {
    _controller.value = TextEditingValue(
      text: edit.text,
      selection: TextSelection.collapsed(offset: edit.caret),
    );
    widget.onChanged(edit.text);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final monospace = theme.textTheme.bodyLarge?.copyWith(
      fontFamily: 'monospace',
    );
    final variables = widget.expression.variables;
    final matches = _suggestions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: monospace,
          minLines: _minLines,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            labelText: l10n.expression_field_expression,
            helperText: l10n.expression_hint_expression,
            helperMaxLines: 3,
            alignLabelWithHint: true,
            border: AppShapes.fieldBorder(),
          ),
          onChanged: widget.onChanged,
        ),
        if (matches.isNotEmpty) ...[
          const SizedBox(height: 4),
          _SuggestionList(
            key: const ValueKey('expression_suggestions'),
            matches: matches,
            highlight: _index(matches),
            maxHeight: _suggestionsHeight,
            onSelected: _accept,
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.expression_formula_variables_label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (variables.isEmpty)
          Text(
            l10n.expression_formula_variables_empty,
            style: theme.textTheme.bodySmall,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final variable in variables)
                Tooltip(
                  message: expressionVariableTypeLabel(l10n, variable.type),
                  child: ActionChip(
                    label: Text(variable.name, style: monospace),
                    onPressed: () => _insert(variable.name),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// The suggestions below the field: a name and its type per row, the
/// [highlight]ed one shaded. Rows do not take focus, so the field keeps it
/// while a row is tapped.
class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.matches,
    required this.highlight,
    required this.maxHeight,
    required this.onSelected,
    super.key,
  });

  final List<ExpressionVariable> matches;
  final int highlight;
  final double maxHeight;
  final ValueChanged<ExpressionVariable> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final monospace = theme.textTheme.bodyMedium?.copyWith(
      fontFamily: 'monospace',
    );
    return Material(
      elevation: 2,
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppShapes.small),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final variable = matches[index];
            return InkWell(
              canRequestFocus: false,
              onTap: () => onSelected(variable),
              child: Container(
                color: index == highlight
                    ? theme.colorScheme.secondaryContainer
                    : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(variable.name, style: monospace)),
                    Text(
                      expressionVariableTypeLabel(l10n, variable.type),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
