import 'package:flutter/material.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/feature/expression/expression_tokens.dart';

/// The formula text, colored by token: functions, variables and constants
/// stand out from the numbers, strings and operators. The colors come from the
/// theme, so light and dark both work.
///
/// The names the highlighting needs (the catalog and the declared variables)
/// are set with [setNames]; the text itself is what the field edits.
class ExpressionFormulaController extends TextEditingController {
  ExpressionFormulaController({super.text});

  ExpressionCatalog? _catalog;
  List<String> _variables = const [];

  /// Gives the catalog and the declared variables to the highlighting. Does
  /// not notify: the field calls it while it builds, before the text is drawn.
  void setNames({
    required ExpressionCatalog? catalog,
    required List<String> variables,
  }) {
    _catalog = catalog;
    _variables = variables;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    required bool withComposing,
    TextStyle? style,
  }) {
    // The keyboard underlines the word it is still composing, which the
    // highlighting would hide. It is only for that moment.
    if (withComposing && value.isComposingRangeValid) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final colors = Theme.of(context).colorScheme;
    final source = text;
    final tokens = tokenizeFormula(
      source,
      catalog: _catalog,
      variables: _variables,
    );
    return TextSpan(
      style: style,
      children: [
        for (final token in tokens)
          TextSpan(
            text: token.textIn(source),
            style: _styleOf(token.kind, colors),
          ),
      ],
    );
  }

  static TextStyle? _styleOf(ExpressionTokenKind kind, ColorScheme colors) {
    return switch (kind) {
      ExpressionTokenKind.number => TextStyle(color: colors.tertiary),
      ExpressionTokenKind.string => TextStyle(
        color: colors.secondary,
        fontStyle: FontStyle.italic,
      ),
      ExpressionTokenKind.function => TextStyle(
        color: colors.primary,
        fontWeight: FontWeight.w600,
      ),
      ExpressionTokenKind.variable => TextStyle(color: colors.secondary),
      ExpressionTokenKind.constant => TextStyle(
        color: colors.tertiary,
        fontStyle: FontStyle.italic,
      ),
      ExpressionTokenKind.unknown => TextStyle(color: colors.error),
      ExpressionTokenKind.operator => TextStyle(
        color: colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      ExpressionTokenKind.punctuation => TextStyle(
        color: colors.onSurfaceVariant,
      ),
      ExpressionTokenKind.whitespace => null,
    };
  }
}
