import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/feature/expression/expression_completion.dart';
import 'package:stelaris/feature/expression/expression_variable_dialog.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The formula as a large multi-line field. While an identifier is typed the
/// variables, constants and functions it starts are suggested, and a function
/// call shows its signature with the parameter at the caret highlighted. The
/// variables are also listed as chips to insert. [onChanged] gets every new
/// text; the field keeps its own controller, so typing does not move the caret
/// when the store rebuilds.
class ExpressionFormulaField extends StatefulWidget {
  const ExpressionFormulaField({
    required this.expression,
    required this.onChanged,
    this.catalog,
    super.key,
  });

  final ExpressionModel expression;
  final ValueChanged<String> onChanged;

  /// The EvalEx catalog for the constants, functions and signatures. Null
  /// while it is not loaded: only the variables are suggested then.
  final ExpressionCatalog? catalog;

  @override
  State<ExpressionFormulaField> createState() => _ExpressionFormulaFieldState();
}

class _ExpressionFormulaFieldState extends State<ExpressionFormulaField> {
  static const int _minLines = 8;

  /// Rows of the suggestion list, and how many are visible before it scrolls.
  static const double _rowHeight = 40;
  static const int _visibleRows = 8;
  static const double _suggestionsHeight = _rowHeight * _visibleRows + 8;

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

  /// The identifier before the caret, or null when the field is not focused,
  /// the selection is a range or no identifier ends at the caret.
  IdentifierPrefix? _prefixAtCaret() {
    if (!_focusNode.hasFocus) return null;
    final value = _controller.value;
    if (!value.selection.isCollapsed) return null;
    return identifierPrefixAt(value.text, value.selection.baseOffset);
  }

  /// The suggestions for the identifier before the caret, empty when the
  /// field is not focused, nothing is typed or Escape closed the list.
  List<FormulaSuggestion> _suggestions() {
    if (_dismissed) return const [];
    final prefix = _prefixAtCaret();
    if (prefix == null) return const [];
    return formulaSuggestions(
      prefix: prefix.text,
      variables: widget.expression.variables,
      catalog: widget.catalog,
    );
  }

  /// The signature of the function call the caret is in, if any. Shown while
  /// the field has focus, also after Escape closed the suggestions.
  SignatureHelp? _signature() {
    if (!_focusNode.hasFocus) return null;
    final value = _controller.value;
    if (!value.selection.isCollapsed) return null;
    return signatureHelpAt(
      value.text,
      value.selection.baseOffset,
      widget.catalog,
    );
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
  int _index(List<FormulaSuggestion> matches) =>
      _highlight < matches.length ? _highlight : 0;

  /// Completes the identifier before the caret to [suggestion].
  void _accept(FormulaSuggestion suggestion) {
    final value = _controller.value;
    final prefix = identifierPrefixAt(value.text, value.selection.baseOffset);
    if (prefix == null) return;
    _apply(
      completeSuggestion(
        value.text,
        prefix,
        value.selection.baseOffset,
        suggestion,
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
    final signature = _signature();
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
        if (signature != null) ...[
          const SizedBox(height: 4),
          _SignaturePanel(
            key: const ValueKey('expression_signature'),
            help: signature,
          ),
        ],
        if (matches.isNotEmpty) ...[
          const SizedBox(height: 4),
          _SuggestionList(
            key: const ValueKey('expression_suggestions'),
            matches: matches,
            highlight: _index(matches),
            rowHeight: _rowHeight,
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

/// The signature of the function the caret is in, with the parameter at the
/// caret in bold. Its text is the signature, so it reads the same in any
/// language.
class _SignaturePanel extends StatelessWidget {
  const _SignaturePanel({required this.help, super.key});

  final SignatureHelp help;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monospace = theme.textTheme.bodyMedium?.copyWith(
      fontFamily: 'monospace',
    );
    final labels = help.labels;
    final spans = <TextSpan>[TextSpan(text: '${help.function.name}(')];
    for (var i = 0; i < labels.length; i++) {
      if (i > 0) spans.add(const TextSpan(text: ', '));
      spans.add(
        TextSpan(
          text: labels[i],
          style: i == help.highlighted
              ? const TextStyle(fontWeight: FontWeight.bold)
              : null,
        ),
      );
    }
    spans.add(const TextSpan(text: ')'));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppShapes.small),
      ),
      child: Text.rich(TextSpan(style: monospace, children: spans)),
    );
  }
}

/// The suggestions below the field, one row each: the name or signature, and
/// what kind it is. The [highlight]ed row is shaded. Rows do not take focus,
/// so the field keeps it while a row is tapped.
class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.matches,
    required this.highlight,
    required this.rowHeight,
    required this.maxHeight,
    required this.onSelected,
    super.key,
  });

  final List<FormulaSuggestion> matches;
  final int highlight;
  final double rowHeight;
  final double maxHeight;
  final ValueChanged<FormulaSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final monospace = theme.textTheme.bodyMedium?.copyWith(
      fontFamily: 'monospace',
    );
    final kindStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
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
            final suggestion = matches[index];
            final (label, kind) = switch (suggestion) {
              VariableSuggestion(:final variable) => (
                variable.name,
                expressionVariableTypeLabel(l10n, variable.type),
              ),
              ConstantSuggestion(:final constant) => (
                constant.name,
                l10n.expression_suggestion_constant(constant.value),
              ),
              FunctionSuggestion(:final function) => (
                functionSignature(function),
                l10n.expression_suggestion_function,
              ),
            };
            return InkWell(
              canRequestFocus: false,
              onTap: () => onSelected(suggestion),
              child: Container(
                height: rowHeight,
                color: index == highlight
                    ? theme.colorScheme.secondaryContainer
                    : null,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: monospace,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(kind, style: kindStyle),
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
