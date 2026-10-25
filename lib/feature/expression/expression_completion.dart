import 'package:stelaris/api/model/expression_catalog_model.dart';
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

/// A name the formula editor offers while an identifier is typed.
sealed class FormulaSuggestion {
  const FormulaSuggestion();

  /// The name the suggestion stands for, as declared or as the catalog has it.
  String get name;
}

/// A variable declared on the expression.
final class VariableSuggestion extends FormulaSuggestion {
  const VariableSuggestion(this.variable);

  final ExpressionVariable variable;

  @override
  String get name => variable.name;
}

/// A constant of the EvalEx catalog, such as `PI`.
final class ConstantSuggestion extends FormulaSuggestion {
  const ConstantSuggestion(this.constant);

  final CatalogConstant constant;

  @override
  String get name => constant.name;
}

/// A function of the EvalEx catalog, completed with its opening parenthesis.
final class FunctionSuggestion extends FormulaSuggestion {
  const FunctionSuggestion(this.function);

  final CatalogFunction function;

  @override
  String get name => function.name;
}

/// The function whose argument list the caret is in, and the index of the
/// argument the caret is at (the number of commas before it at that level).
class CallSite {
  const CallSite({required this.name, required this.argumentIndex});

  final String name;
  final int argumentIndex;
}

/// The signature of a function with the parameter the caret is at.
class SignatureHelp {
  const SignatureHelp({required this.function, required this.highlighted});

  final CatalogFunction function;

  /// Index into [labels] of the parameter the caret is at, or null when the
  /// call has more arguments than the function takes.
  final int? highlighted;

  /// The parameters as shown in the signature, see [parameterLabels].
  List<String> get labels => parameterLabels(function);

  /// The signature as text, such as `ROUND(value, precision)`.
  String get text => functionSignature(function);
}

/// The parameters of [function] as shown in a signature: `value` for a plain
/// parameter, `value…` for a vararg one.
List<String> parameterLabels(CatalogFunction function) => [
  for (final parameter in function.parameters)
    parameter.varArg ? '${parameter.name}…' : parameter.name,
];

/// The signature of [function] as text, such as `ROUND(value, precision)`.
String functionSignature(CatalogFunction function) =>
    '${function.name}(${parameterLabels(function).join(', ')})';

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

/// Whether [name] is suggested for [prefix]: it starts with the prefix
/// ignoring case, and it is not the prefix itself, as there is nothing left to
/// complete. An empty prefix matches nothing.
bool _suggests(String name, String prefix) =>
    prefix.isNotEmpty &&
    name != prefix &&
    name.toLowerCase().startsWith(prefix.toLowerCase());

/// Sorts [items] by name, ignoring case, so the order does not depend on how
/// they were declared or listed.
List<T> _byName<T>(Iterable<T> items, String Function(T) nameOf) {
  final sorted = items.toList()
    ..sort((a, b) {
      final byLower = nameOf(a)
          .toLowerCase()
          .compareTo(nameOf(b).toLowerCase());
      return byLower != 0 ? byLower : nameOf(a).compareTo(nameOf(b));
    });
  return sorted;
}

/// The variables whose name matches [prefix] (see [_suggests]), sorted by name.
List<ExpressionVariable> variableSuggestions(
  List<ExpressionVariable> variables,
  String prefix,
) => _byName(
  variables.where((variable) => _suggests(variable.name, prefix)),
  (variable) => variable.name,
);

/// Everything the formula editor offers for [prefix]: the matching variables,
/// then the matching constants, then the matching functions. Each group is
/// sorted by name. Without a [catalog] only the variables are offered.
List<FormulaSuggestion> formulaSuggestions({
  required String prefix,
  required List<ExpressionVariable> variables,
  ExpressionCatalog? catalog,
}) {
  if (prefix.isEmpty) return const [];
  final constants = catalog?.constants ?? const <CatalogConstant>[];
  final functions = catalog?.functions ?? const <CatalogFunction>[];
  return [
    for (final variable in variableSuggestions(variables, prefix))
      VariableSuggestion(variable),
    for (final constant in _byName(
      constants.where((constant) => _suggests(constant.name, prefix)),
      (constant) => constant.name,
    ))
      ConstantSuggestion(constant),
    for (final function in _byName(
      functions.where((function) => _suggests(function.name, prefix)),
      (function) => function.name,
    ))
      FunctionSuggestion(function),
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

/// Completes [prefix] at [caret] to the [suggestion] the user chose.
///
/// A constant or variable is inserted by its name. A function is inserted as
/// `NAME(` with the caret after the parenthesis, unless the text already has
/// a `(` right after the caret: then only the name is completed, so no second
/// parenthesis appears.
FormulaEdit completeSuggestion(
  String text,
  IdentifierPrefix prefix,
  int caret,
  FormulaSuggestion suggestion,
) {
  if (suggestion is! FunctionSuggestion) {
    return replaceFormulaRange(text, prefix.start, caret, suggestion.name);
  }
  final name = suggestion.name;
  final hasParenthesis = caret < text.length && text[caret] == '(';
  return replaceFormulaRange(
    text,
    prefix.start,
    caret,
    hasParenthesis ? name : '$name(',
  );
}

/// The function call whose argument list [caret] is in, or null when the caret
/// is in no call. Brackets are matched left of the caret, and commas count
/// only at the level of the call's own brackets. Text inside a "..." or '...'
/// string literal is ignored. A bracket that is not a call (a grouping
/// bracket such as `(a + b)`) is skipped, so the call around it is found.
CallSite? enclosingCall(String text, int caret) {
  if (caret < 0 || caret > text.length) return null;
  // One frame per open bracket: the call's name, or null for a grouping
  // bracket, and the commas seen directly inside it.
  final frames = <_BracketFrame>[];
  String? openQuote;
  for (var i = 0; i < caret; i++) {
    final char = text[i];
    if (openQuote != null) {
      if (char == openQuote) openQuote = null;
      continue;
    }
    if (char == '"' || char == "'") {
      openQuote = char;
    } else if (char == '(') {
      frames.add(_BracketFrame(_callNameBefore(text, i)));
    } else if (char == ')') {
      if (frames.isNotEmpty) frames.removeLast();
    } else if (char == ',') {
      if (frames.isNotEmpty) frames.last.commas++;
    }
  }
  for (final frame in frames.reversed) {
    final name = frame.name;
    if (name != null) {
      return CallSite(name: name, argumentIndex: frame.commas);
    }
  }
  return null;
}

/// The identifier right before the bracket at [openIndex], or null when the
/// bracket is not preceded by one.
String? _callNameBefore(String text, int openIndex) {
  var start = openIndex;
  while (start > 0 && _identifierChar.hasMatch(text[start - 1])) {
    start--;
  }
  if (start == openIndex || !_identifierStart.hasMatch(text[start])) {
    return null;
  }
  return text.substring(start, openIndex);
}

class _BracketFrame {
  _BracketFrame(this.name);

  final String? name;
  int commas = 0;
}

/// The signature help for the caret at [caret] in [text]: the function of the
/// call the caret is in, with the parameter at the caret highlighted. Null
/// when the caret is in no call or the call names no catalog function.
SignatureHelp? signatureHelpAt(
  String text,
  int caret,
  ExpressionCatalog? catalog,
) {
  if (catalog == null) return null;
  final call = enclosingCall(text, caret);
  if (call == null) return null;
  final lower = call.name.toLowerCase();
  CatalogFunction? function;
  for (final candidate in catalog.functions) {
    if (candidate.name.toLowerCase() == lower) {
      function = candidate;
      break;
    }
  }
  if (function == null) return null;
  return SignatureHelp(
    function: function,
    highlighted: _highlightedParameter(function, call.argumentIndex),
  );
}

/// The parameter an argument at [index] binds to. Past the last parameter, a
/// vararg last parameter takes the arguments, otherwise nothing is highlighted.
int? _highlightedParameter(CatalogFunction function, int index) {
  final parameters = function.parameters;
  if (parameters.isEmpty) return null;
  if (index < parameters.length) return index;
  return parameters.last.varArg ? parameters.length - 1 : null;
}
