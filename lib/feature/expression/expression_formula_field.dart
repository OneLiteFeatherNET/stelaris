import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/model/expression_validation_model.dart';
import 'package:stelaris/feature/expression/expression_completion.dart';
import 'package:stelaris/feature/expression/expression_formula_controller.dart';
import 'package:stelaris/feature/expression/expression_function_sidebar.dart';
import 'package:stelaris/feature/expression/expression_operator_toolbar.dart';
import 'package:stelaris/feature/expression/expression_variable_dialog.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The formula as a large multi-line field, with an operator toolbar above it
/// and, beside it on wide layouts (below it on narrow ones), the functions and
/// constants to browse. While an identifier is typed the variables, constants
/// and functions it starts are suggested, and a function call shows its
/// signature with the parameter at the caret highlighted. The variables are
/// also listed as chips to insert. The text is colored by token. [onChanged]
/// gets every new text; the field keeps its own controller, so typing does not
/// move the caret when the store rebuilds.
///
/// [validation] is the backend's check of the current text, when there is one:
/// its errors are underlined and listed, undefined variables are offered for
/// declaration, and unused declared variables are marked on their chips.
class ExpressionFormulaField extends StatefulWidget {
  const ExpressionFormulaField({
    required this.expression,
    required this.onChanged,
    this.catalog,
    this.validation,
    this.onDeclare,
    super.key,
  });

  final ExpressionModel expression;
  final ValueChanged<String> onChanged;

  /// The EvalEx catalog for the constants, functions and signatures. Null
  /// while it is not loaded: only the variables are suggested then.
  final ExpressionCatalog? catalog;

  /// The backend's check of the current text, null when there is none.
  final ExpressionValidation? validation;

  /// Declares the given names, as written in the formula, as variables. Null
  /// hides the declare actions.
  final ValueChanged<List<String>>? onDeclare;

  @override
  State<ExpressionFormulaField> createState() => _ExpressionFormulaFieldState();
}

class _ExpressionFormulaFieldState extends State<ExpressionFormulaField> {
  static const int _minLines = 8;

  /// From this width the functions sidebar sits beside the editor.
  static const double _wideLayoutWidth = 1000;
  static const double _sidebarWidth = 300;

  /// Rows of the suggestion list, and how many are visible before it scrolls.
  static const double _rowHeight = 40;
  static const int _visibleRows = 8;
  static const double _suggestionsHeight = _rowHeight * _visibleRows + 8;

  late final ExpressionFormulaController _controller;
  late final FocusNode _focusNode;

  /// The highlighted suggestion, moved with the arrow keys.
  int _highlight = 0;

  /// Set by Escape, cleared when the text changes again.
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = ExpressionFormulaController(
      text: widget.expression.expression,
    )..addListener(_onControllerChanged);
    _updateNames();
    // The focus node handles keys before the text field's own shortcuts do,
    // so Enter, Tab and the arrows can be taken while suggestions are open.
    _focusNode = FocusNode(onKeyEvent: _handleKey)..addListener(_refresh);
  }

  @override
  void didUpdateWidget(ExpressionFormulaField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateNames();
    final text = widget.expression.expression;
    // Another expression was selected, or the store's text no longer matches
    // the field (e.g. unsaved changes were discarded). Typing stages the same
    // text, so it never matches the store as a change and the caret stays.
    if (oldWidget.expression.id != widget.expression.id) {
      _controller.value = TextEditingValue(text: text);
    } else if (text != _controller.text) {
      _replaceText(text);
    }
  }

  /// Shows [text] and keeps the caret where it was, clamped to the new text.
  void _replaceText(String text) {
    final selection = _controller.selection;
    final base = selection.isValid
        ? selection.baseOffset.clamp(0, text.length)
        : text.length;
    final extent = selection.isValid
        ? selection.extentOffset.clamp(0, text.length)
        : text.length;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: base, extentOffset: extent),
    );
  }

  void _updateNames() => _controller.setNames(
    catalog: widget.catalog,
    variables: [
      for (final variable in widget.expression.variables) variable.name,
    ],
    validation: widget.validation,
  );

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

  /// Edits the selection, or the caret when nothing is selected (the text end
  /// when the caret was never placed). [build] gets the text and the range.
  void _edit(FormulaEdit Function(String text, int start, int end) build) {
    final value = _controller.value;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;
    _apply(build(value.text, start, end));
  }

  void _insert(String name) =>
      _edit((text, start, end) => replaceFormulaRange(text, start, end, name));

  void _insertFunction(CatalogFunction function) => _edit(
    (text, start, end) => insertFunctionCall(text, start, end, function.name),
  );

  void _insertOperator(OperatorSymbol operator) =>
      _edit((text, start, end) => insertOperator(text, start, end, operator));

  void _insertPunctuation(String symbol) => _edit(
    (text, start, end) => symbol == ','
        ? replaceFormulaRange(text, start, end, ',')
        : insertParenthesis(text, start, end, open: symbol == '('),
  );

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
    final validation = widget.validation;
    final unused = {
      for (final name in validation?.unusedVariables ?? const <String>[])
        name.toLowerCase(),
    };
    final matches = _suggestions();
    final signature = _signature();
    final editor = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExpressionOperatorToolbar(
          catalog: widget.catalog,
          onOperator: _insertOperator,
          onPunctuation: _insertPunctuation,
        ),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('expression_formula_text'),
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
        if (validation != null)
          _ValidationNotes(validation: validation, onDeclare: widget.onDeclare),
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
                if (unused.contains(variable.name.toLowerCase()))
                  Tooltip(
                    message: l10n.expression_variable_unused,
                    child: ActionChip(
                      key: ValueKey('expression_chip_unused_${variable.name}'),
                      label: Text(
                        variable.name,
                        style: monospace?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onPressed: () => _insert(variable.name),
                    ),
                  )
                else
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
    final sidebar = ExpressionFunctionSidebar(
      catalog: widget.catalog,
      onFunction: _insertFunction,
      onConstant: (constant) => _insert(constant.name),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _wideLayoutWidth) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: editor),
              const SizedBox(width: 24),
              SizedBox(width: _sidebarWidth, child: sidebar),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [editor, const SizedBox(height: 24), sidebar],
        );
      },
    );
  }
}

/// What the backend's check says about the formula, under the field: its
/// errors when it does not parse, the names it reads but does not declare with
/// a way to declare them, or a small check when it is valid.
class _ValidationNotes extends StatelessWidget {
  const _ValidationNotes({required this.validation, this.onDeclare});

  final ExpressionValidation validation;

  /// Declares the given names. Null hides the declare actions.
  final ValueChanged<List<String>>? onDeclare;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final undefined = validation.undefinedVariables;
    final children = <Widget>[];
    if (!validation.valid) {
      children.add(
        Column(
          key: const ValueKey('expression_errors'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final error in validation.errors)
              Text(
                error.message,
                style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
              ),
          ],
        ),
      );
    }
    if (undefined.isNotEmpty) {
      children.add(
        Wrap(
          key: const ValueKey('expression_undefined'),
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              l10n.expression_validation_undefined(undefined.join(', ')),
              style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
            ),
            if (onDeclare != null) ...[
              for (final name in undefined)
                TextButton(
                  key: ValueKey('expression_declare_$name'),
                  onPressed: () => onDeclare!([name]),
                  child: Text(l10n.expression_validation_declare),
                ),
              if (undefined.length > 1)
                TextButton(
                  key: const ValueKey('expression_declare_all'),
                  onPressed: () => onDeclare!(undefined),
                  child: Text(l10n.expression_validation_declare_all),
                ),
            ],
          ],
        ),
      );
    }
    if (validation.valid && undefined.isEmpty) {
      children.add(
        Row(
          key: const ValueKey('expression_valid'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 16, color: colors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              l10n.expression_validation_valid,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
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
