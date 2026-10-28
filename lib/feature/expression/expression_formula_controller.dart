import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/api/model/expression_validation_model.dart';
import 'package:stelaris/feature/expression/expression_tokens.dart';

/// The formula text, colored by token: functions, variables and constants
/// stand out from the numbers, strings and operators. The colors come from the
/// theme, so light and dark both work.
///
/// The names the highlighting needs (the catalog and the declared variables)
/// are set with [setNames], together with the backend's check of the formula,
/// whose errors get a wavy underline and whose undefined variables keep the
/// error color. The text itself is what the field edits.
class ExpressionFormulaController extends TextEditingController {
  ExpressionFormulaController({super.text});

  ExpressionCatalog? _catalog;
  List<String> _variables = const [];
  List<ExpressionValidationError> _errors = const [];
  Set<String> _undefined = const {};

  /// Gives the catalog, the declared variables and the backend's check to the
  /// highlighting. A null [validation] means there is no check for the text.
  /// Does not notify: the field calls it while it builds, before the text is
  /// drawn.
  void setNames({
    required ExpressionCatalog? catalog,
    required List<String> variables,
    ExpressionValidation? validation,
  }) {
    _catalog = catalog;
    _variables = variables;
    _errors = validation?.errors ?? const [];
    _undefined = {
      for (final name in validation?.undefinedVariables ?? const <String>[])
        name.toLowerCase(),
    };
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
    final ranges = _fittingErrors(source.length);
    final cuts = <int>{0, source.length};
    for (final token in tokens) {
      cuts
        ..add(token.start)
        ..add(token.end);
    }
    for (final range in ranges) {
      cuts
        ..add(range.start)
        ..add(range.end);
    }
    final sorted = cuts.toList()..sort();
    final children = <TextSpan>[];
    for (var i = 0; i + 1 < sorted.length; i++) {
      final from = sorted[i];
      final to = sorted[i + 1];
      final token = tokens.firstWhere(
        (token) => token.start <= from && from < token.end,
      );
      var segmentStyle = _styleOf(_kindFor(token, source), colors);
      if (ranges.any((range) => range.start <= from && from < range.end)) {
        segmentStyle = (segmentStyle ?? const TextStyle()).copyWith(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.wavy,
          decorationColor: colors.error,
        );
      }
      children.add(
        TextSpan(text: source.substring(from, to), style: segmentStyle),
      );
    }
    return TextSpan(style: style, children: children);
  }

  /// The errors that lie inside [length] characters and cover some text. The
  /// check was made for another text when they do not, and they are skipped.
  List<ExpressionValidationError> _fittingErrors(int length) => [
    for (final error in _errors)
      if (error.start >= 0 && error.start < error.end && error.end <= length)
        error,
  ];

  /// The kind a token is drawn with. An identifier the backend reports as
  /// undefined is an error, whatever the local lookup made of it.
  ExpressionTokenKind _kindFor(ExpressionToken token, String source) {
    if (token.kind == ExpressionTokenKind.function ||
        token.kind == ExpressionTokenKind.unknown) {
      return token.kind;
    }
    final name = token.textIn(source).toLowerCase();
    if (_undefined.contains(name)) return ExpressionTokenKind.unknown;
    return token.kind;
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
