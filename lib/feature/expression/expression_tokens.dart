import 'package:stelaris_models/stelaris_models.dart';

/// What a run of formula text is, for the syntax highlighting.
enum ExpressionTokenKind {
  number,
  string,

  /// A catalog function called right after its name, such as `ROUND(`.
  function,

  /// A variable declared on the expression.
  variable,

  /// A catalog constant, such as `PI`.
  constant,

  /// An identifier that is none of the above, e.g. a typo or an undeclared
  /// variable.
  unknown,
  operator,
  punctuation,
  whitespace,
}

/// A run of formula text from [start] up to [end] (exclusive) and its kind.
/// The tokens of a formula cover the whole text, in order, without gaps.
class ExpressionToken {
  const ExpressionToken({
    required this.kind,
    required this.start,
    required this.end,
  });

  final ExpressionTokenKind kind;
  final int start;
  final int end;

  /// The part of [source] this token covers.
  String textIn(String source) => source.substring(start, end);

  @override
  bool operator ==(Object other) =>
      other is ExpressionToken &&
      other.kind == kind &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(kind, start, end);

  @override
  String toString() => 'ExpressionToken($kind, $start, $end)';
}

/// Operators the formula is known to use, when the catalog is not loaded.
const List<String> fallbackOperatorSymbols = [
  '+',
  '-',
  '*',
  '/',
  '^',
  '%',
  '==',
  '!=',
  '<',
  '<=',
  '>',
  '>=',
  '&&',
  '||',
  '!',
];

const String _operatorChars = '+-*/^%=!<>&|';

/// Splits [text] into tokens for the syntax highlighting. Names are matched
/// ignoring case: a name is a [function] when it is directly followed by `(`
/// (after optional spaces) and names a catalog function, otherwise a
/// [variable] when declared in [variables], otherwise a [constant] when the
/// catalog has it, otherwise [unknown]. Operators are matched longest first,
/// so `&&` and `>=` are one token. A string runs to its closing quote, or to
/// the end of the text when it is unterminated.
List<ExpressionToken> tokenizeFormula(
  String text, {
  ExpressionCatalog? catalog,
  Iterable<String> variables = const [],
}) {
  final functions = {
    for (final function in catalog?.functions ?? const <CatalogFunction>[])
      function.name.toLowerCase(),
  };
  final constants = {
    for (final constant in catalog?.constants ?? const <CatalogConstant>[])
      constant.name.toLowerCase(),
  };
  final declared = {for (final name in variables) name.toLowerCase()};
  final operators = {
    ...fallbackOperatorSymbols,
    for (final operator in catalog?.operators ?? const <CatalogOperator>[])
      operator.symbol,
  }.where((symbol) => symbol.isNotEmpty && !_isIdentifierStart(symbol[0]));

  final tokens = <ExpressionToken>[];
  void add(ExpressionTokenKind kind, int start, int end) =>
      tokens.add(ExpressionToken(kind: kind, start: start, end: end));

  var i = 0;
  while (i < text.length) {
    final char = text[i];
    if (_isSpace(char)) {
      final end = _runEnd(text, i, _isSpace);
      add(ExpressionTokenKind.whitespace, i, end);
      i = end;
    } else if (char == '"' || char == "'") {
      final close = text.indexOf(char, i + 1);
      final end = close < 0 ? text.length : close + 1;
      add(ExpressionTokenKind.string, i, end);
      i = end;
    } else if (_isDigit(char) ||
        (char == '.' && i + 1 < text.length && _isDigit(text[i + 1]))) {
      final end = _numberEnd(text, i);
      add(ExpressionTokenKind.number, i, end);
      i = end;
    } else if (_isIdentifierStart(char)) {
      final end = _runEnd(text, i, _isIdentifierPart);
      final name = text.substring(i, end).toLowerCase();
      final kind = _isCallAt(text, end)
          ? (functions.contains(name)
                ? ExpressionTokenKind.function
                : ExpressionTokenKind.unknown)
          : declared.contains(name)
          ? ExpressionTokenKind.variable
          : constants.contains(name)
          ? ExpressionTokenKind.constant
          : ExpressionTokenKind.unknown;
      add(kind, i, end);
      i = end;
    } else if (_operatorChars.contains(char)) {
      final end = _longestOperatorEnd(text, i, operators);
      add(ExpressionTokenKind.operator, i, end);
      i = end;
    } else {
      add(ExpressionTokenKind.punctuation, i, i + 1);
      i++;
    }
  }
  return tokens;
}

/// Whether a `(` follows [end] after optional spaces.
bool _isCallAt(String text, int end) {
  var i = end;
  while (i < text.length && (text[i] == ' ' || text[i] == '\t')) {
    i++;
  }
  return i < text.length && text[i] == '(';
}

/// The end of the number starting at [start]: digits, an optional fraction
/// and an exponent, which is taken only when digits follow it.
int _numberEnd(String text, int start) {
  var i = _runEnd(text, start, _isDigit);
  if (i < text.length && text[i] == '.') {
    i = _runEnd(text, i + 1, _isDigit);
  }
  if (i < text.length && (text[i] == 'e' || text[i] == 'E')) {
    var j = i + 1;
    if (j < text.length && (text[j] == '+' || text[j] == '-')) j++;
    if (j < text.length && _isDigit(text[j])) {
      i = _runEnd(text, j, _isDigit);
    }
  }
  return i;
}

/// The end of the operator starting at [start]: the longest known symbol
/// that matches there, or one character when none does.
int _longestOperatorEnd(String text, int start, Iterable<String> symbols) {
  var best = start + 1;
  for (final symbol in symbols) {
    if (symbol.length > best - start && text.startsWith(symbol, start)) {
      best = start + symbol.length;
    }
  }
  return best;
}

/// The end of the run of characters from [start] that satisfy [test].
int _runEnd(String text, int start, bool Function(String) test) {
  var i = start;
  while (i < text.length && test(text[i])) {
    i++;
  }
  return i;
}

bool _isSpace(String char) =>
    char == ' ' || char == '\t' || char == '\n' || char == '\r';

bool _isDigit(String char) =>
    char.codeUnitAt(0) >= 0x30 && char.codeUnitAt(0) <= 0x39;

bool _isIdentifierStart(String char) {
  final code = char.codeUnitAt(0);
  return (code >= 0x41 && code <= 0x5a) ||
      (code >= 0x61 && code <= 0x7a) ||
      code == 0x5f;
}

bool _isIdentifierPart(String char) =>
    _isIdentifierStart(char) || _isDigit(char);
