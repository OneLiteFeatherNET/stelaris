import 'package:stelaris/api/model/expression_model.dart';

/// The identifier being typed left of a caret in a formula: its start offset
/// and the characters from there to the caret.
class IdentifierPrefix {
  const IdentifierPrefix({required this.start, required this.text});

  /// Offset of the first character of the identifier in the formula.
  final int start;

  /// The characters from [start] up to the caret.
  final String text;
}

/// A formula after an edit, with the caret offset to put back in it.
class FormulaEdit {
  const FormulaEdit({required this.text, required this.caret});

  final String text;
  final int caret;
}

final RegExp _identifierChar = RegExp(r'[A-Za-z0-9_]');
final RegExp _identifierStart = RegExp(r'[A-Za-z_]');

/// The identifier that ends at [caret] in [text], or null when there is none.
/// A run of identifier characters counts only when it starts with a letter or
/// underscore, so the digits of a number such as `2abc` give no prefix.
IdentifierPrefix? identifierPrefixAt(String text, int caret) {
  if (caret < 0 || caret > text.length) return null;
  var start = caret;
  while (start > 0 && _identifierChar.hasMatch(text[start - 1])) {
    start--;
  }
  if (start == caret || !_identifierStart.hasMatch(text[start])) return null;
  return IdentifierPrefix(start: start, text: text.substring(start, caret));
}

/// The variables whose name starts with [prefix], ignoring case, in declared
/// order. A name that equals the prefix exactly is left out, as there is
/// nothing left to complete. An empty prefix matches nothing.
List<ExpressionVariable> variableSuggestions(
  List<ExpressionVariable> variables,
  String prefix,
) {
  if (prefix.isEmpty) return const [];
  final lower = prefix.toLowerCase();
  return [
    for (final variable in variables)
      if (variable.name != prefix &&
          variable.name.toLowerCase().startsWith(lower))
        variable,
  ];
}

/// Replaces the text from [start] to [end] with [insert]. The caret goes
/// after the inserted text.
FormulaEdit replaceFormulaRange(
  String text,
  int start,
  int end,
  String insert,
) {
  final edited = text.substring(0, start) + insert + text.substring(end);
  return FormulaEdit(text: edited, caret: start + insert.length);
}

/// Completes [prefix] at [caret] to the full [name] of a variable.
FormulaEdit completeVariable(
  String text,
  IdentifierPrefix prefix,
  int caret,
  String name,
) => replaceFormulaRange(text, prefix.start, caret, name);
