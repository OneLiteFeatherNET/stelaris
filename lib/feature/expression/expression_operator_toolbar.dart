import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/expression/expression_completion.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// One compact button per operator above the formula field, then the
/// parentheses and the argument separator, and last the button that opens the
/// function picker. Taps count as taps inside the field, so the field keeps its
/// focus and selection.
class ExpressionOperatorToolbar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final monospace = Theme.of(context).textTheme.labelLarge
        ?.copyWith(fontFamily: 'monospace');
    return TextFieldTapRegion(
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final operator in operatorSymbols(catalog))
            Tooltip(
              message: _tooltip(l10n, operator),
              child: _ToolbarButton(
                key: ValueKey('expression_operator_${operator.symbol}'),
                label: operator.symbol,
                style: monospace,
                onPressed: () => onOperator(operator),
              ),
            ),
          const SizedBox(width: 8),
          for (final symbol in const ['(', ')', ','])
            Tooltip(
              message: symbol == ','
                  ? l10n.expression_toolbar_comma
                  : l10n.expression_toolbar_parenthesis,
              child: _ToolbarButton(
                key: ValueKey('expression_punctuation_$symbol'),
                label: symbol,
                style: monospace,
                onPressed: () => onPunctuation(symbol),
              ),
            ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            key: const ValueKey('expression_insert_function'),
            onPressed: onInsertFunction,
            icon: const Icon(Icons.functions),
            label: Text(l10n.expression_insert_function),
          ),
        ],
      ),
    );
  }

  /// The kind of [operator], with its precedence when the catalog gives one.
  static String _tooltip(AppLocalizations l10n, OperatorSymbol operator) {
    final kind = switch (operator.kind) {
      CatalogOperatorKind.infix => l10n.expression_operator_kind_infix,
      CatalogOperatorKind.prefix => l10n.expression_operator_kind_prefix,
      CatalogOperatorKind.postfix => l10n.expression_operator_kind_postfix,
      CatalogOperatorKind.other => l10n.expression_operator_kind_other,
    };
    final precedence = operator.precedence;
    return precedence == null
        ? kind
        : l10n.expression_operator_tooltip(kind, precedence);
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
      ),
      child: Text(label, style: style),
    );
  }
}
