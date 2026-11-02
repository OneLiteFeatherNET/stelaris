import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/expression/expression_completion.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The operators above the formula field in groups, see
/// [groupOperatorSymbols], each group on a tinted surface of its own: arithmetic,
/// comparison and logic. Then the parentheses and the argument separator, and
/// last the button that opens the function picker. Of two symbols that mean
/// the same only one is shown, the other is named in its tooltip. Taps count as
/// taps inside the field, so the field keeps its focus and selection.
class ExpressionOperatorToolbar extends StatefulWidget {
  const ExpressionOperatorToolbar({
    required this.catalog,
    required this.onOperator,
    required this.onPunctuation,
    required this.onInsertFunction,
    super.key,
  });

  /// The catalog the operators come from. Null offers the fallback set.
  final ExpressionCatalog? catalog;
  final ValueChanged<OperatorSymbol> onOperator;

  /// Called with `(`, `)` or `,`.
  final ValueChanged<String> onPunctuation;

  /// Opens the picker of the functions and constants.
  final VoidCallback onInsertFunction;

  @override
  State<ExpressionOperatorToolbar> createState() =>
      _ExpressionOperatorToolbarState();

  /// The kind of [operator], with its precedence when the catalog gives one,
  /// and the [alias] it is also written as.
  static String _tooltip(
    AppLocalizations l10n,
    OperatorSymbol operator,
    String? alias,
  ) {
    final kind = switch (operator.kind) {
      CatalogOperatorKind.infix => l10n.expression_operator_kind_infix,
      CatalogOperatorKind.prefix => l10n.expression_operator_kind_prefix,
      CatalogOperatorKind.postfix => l10n.expression_operator_kind_postfix,
      CatalogOperatorKind.other => l10n.expression_operator_kind_other,
    };
    final precedence = operator.precedence;
    final text = precedence == null
        ? kind
        : l10n.expression_operator_tooltip(kind, precedence);
    return alias == null ? text : l10n.expression_operator_alias(text, alias);
  }

  static String _groupLabel(AppLocalizations l10n, OperatorGroupKind kind) =>
      switch (kind) {
        OperatorGroupKind.arithmetic => l10n.expression_operator_group_arithmetic,
        OperatorGroupKind.comparison => l10n.expression_operator_group_comparison,
        OperatorGroupKind.logic => l10n.expression_operator_group_logic,
        OperatorGroupKind.other => l10n.expression_operator_group_other,
      };
}

class _ExpressionOperatorToolbarState extends State<ExpressionOperatorToolbar> {
  /// The catalog [_operators] was listed for. The list is sorted and cleaned
  /// again only when the catalog changes.
  ExpressionCatalog? _catalog;
  List<OperatorGroup>? _groups;

  /// The symbols of the catalog, aliases included, to tell which alias a
  /// shown symbol has.
  Set<String> _symbols = const {};

  /// The operator groups of the current catalog, see [operatorSymbols].
  List<OperatorGroup> _groupsOf(ExpressionCatalog? catalog) {
    final cached = _groups;
    if (cached == null || !identical(catalog, _catalog)) {
      _catalog = catalog;
      final operators = operatorSymbols(catalog);
      _symbols = {for (final operator in operators) operator.symbol};
      _groups = groupOperatorSymbols(operators);
    }
    return _groups!;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final monospace = Theme.of(context).textTheme.labelLarge
        ?.copyWith(fontFamily: 'monospace');
    return TextFieldTapRegion(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final group in _groupsOf(widget.catalog))
            _ToolbarGroup(
              label: ExpressionOperatorToolbar._groupLabel(l10n, group.kind),
              children: [
                for (final operator in group.operators)
                  Tooltip(
                    message: ExpressionOperatorToolbar._tooltip(
                      l10n,
                      operator,
                      _shownAlias(operator.symbol),
                    ),
                    child: _ToolbarButton(
                      key: ValueKey('expression_operator_${operator.symbol}'),
                      label: operator.symbol,
                      style: monospace,
                      onPressed: () => widget.onOperator(operator),
                    ),
                  ),
              ],
            ),
          _ToolbarGroup(
            label: l10n.expression_toolbar_punctuation,
            children: [
              for (final symbol in const ['(', ')', ','])
                Tooltip(
                  message: symbol == ','
                      ? l10n.expression_toolbar_comma
                      : l10n.expression_toolbar_parenthesis,
                  child: _ToolbarButton(
                    key: ValueKey('expression_punctuation_$symbol'),
                    label: symbol,
                    style: monospace,
                    onPressed: () => widget.onPunctuation(symbol),
                  ),
                ),
            ],
          ),
          FilledButton.tonalIcon(
            key: const ValueKey('expression_insert_function'),
            onPressed: widget.onInsertFunction,
            icon: const Icon(Icons.functions),
            label: Text(l10n.expression_insert_function),
          ),
        ],
      ),
    );
  }

  /// The alias of [symbol] the catalog has and the toolbar leaves out.
  String? _shownAlias(String symbol) {
    final alias = operatorAliasOf(symbol);
    return alias != null && _symbols.contains(alias) ? alias : null;
  }
}

/// A group of toolbar buttons on a tinted surface, named by [label] for
/// screen readers.
class _ToolbarGroup extends StatelessWidget {
  const _ToolbarGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: label,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: AppShapes.rounded(AppShapes.small),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.label,
    required this.style,
    required this.onPressed,
    super.key,
  });

  final String label;
  final TextStyle? style;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(40, 36),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        visualDensity: VisualDensity.compact,
        // Fits inside the rounding of its group.
        shape: AppShapes.rounded(AppShapes.extraSmall),
      ),
      child: Text(label, style: style),
    );
  }
}
