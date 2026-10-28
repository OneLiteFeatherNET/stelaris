import 'package:stelaris/feature/expression/expression_tokens.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The LaTeX of the EvalEx [formula], for display only: the formula is still
/// stored and evaluated as text. Returns null when the formula does not parse,
/// so the caller can show the text instead.
///
/// A call is only converted when its name is one of the built-in functions
/// (such as `ROUND` or `IF`) or is in [functionNames], which holds the names of
/// the catalog. Other calls are not known to EvalEx, so they are not converted
/// either. Parentheses are kept only where the precedence needs them.
String? expressionToTex(
  String formula, {
  Set<String> functionNames = const {},
}) {
  final tokens = [
    for (final token in tokenizeFormula(formula))
      if (token.kind != ExpressionTokenKind.whitespace) token,
  ];
  final known = {
    ..._builtinArity.keys,
    ..._variadicBuiltins,
    for (final name in functionNames) name.toLowerCase(),
  };
  try {
    return _TexParser(tokens, formula, known).parse().tex;
  } on _TexException {
    return null;
  }
}

/// The LaTeX of a function definition `name(parameters) = body`, or null when
/// the body does not convert. The name is set as an operator name and the
/// parameters as variables, like the names in the body.
String? functionToTex(
  String name,
  List<String> parameters,
  String body, {
  Set<String> functionNames = const {},
}) {
  if (!_identifier.hasMatch(name)) return null;
  final bodyTex = expressionToTex(body, functionNames: functionNames);
  if (bodyTex == null) return null;
  final head = [for (final parameter in parameters) _variableTex(parameter)];
  return '\\mathrm{${_escapeUnderscore(name.toLowerCase())}}'
      '${_paren(head.join(', '))} = $bodyTex';
}

/// The names of the functions in [catalog], the EvalEx ones and the project's,
/// in the form [expressionToTex] takes. Empty while the catalog is not loaded.
Set<String> catalogFunctionNames(ExpressionCatalog? catalog) => {
  for (final function in catalog?.functions ?? const <CatalogFunction>[])
    function.name,
};

final RegExp _identifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

/// The precedence levels of the EvalEx operators, from the loosest to the
/// tightest. A node needs parentheses in a context that binds tighter.
const int _orLevel = 1;
const int _andLevel = 2;
const int _comparisonLevel = 3;
const int _additiveLevel = 4;
const int _multiplicativeLevel = 5;
const int _unaryLevel = 6;
const int _powerLevel = 7;
const int _atomLevel = 8;

/// Built-in functions with the number of arguments they take.
const Map<String, int> _builtinArity = {
  'sqrt': 1,
  'abs': 1,
  'floor': 1,
  'ceiling': 1,
  'log': 1,
  'log10': 1,
  'sin': 1,
  'cos': 1,
  'tan': 1,
  'round': 2,
  'if': 3,
};

/// Built-in functions that take any number of arguments, at least one.
const Set<String> _variadicBuiltins = {'min', 'max'};

class _TexException implements Exception {
  const _TexException();
}

/// A parsed formula part, with the LaTeX it is drawn as.
sealed class _Node {
  const _Node();

  /// The precedence level of this node, see [_atomLevel].
  int get level;

  /// The LaTeX of this node, without any parentheses added by its context.
  String get tex;
}

class _Atom extends _Node {
  const _Atom(this.tex);

  @override
  final String tex;

  @override
  int get level => _atomLevel;
}

class _Binary extends _Node {
  const _Binary(
    this.symbol,
    this.level,
    this.left,
    this.right, {
    this.comparison = false,
  });

  final String symbol;
  @override
  final int level;
  final _Node left;
  final _Node right;

  /// Comparisons do not chain, so both operands need parentheses at their own
  /// level.
  final bool comparison;

  @override
  String get tex {
    final leftLevel = comparison ? level + 1 : level;
    return '${_wrap(left, leftLevel)} $symbol ${_wrap(right, level + 1)}';
  }
}

class _Unary extends _Node {
  const _Unary(this.prefix, this.operand);

  final String prefix;
  final _Node operand;

  @override
  int get level => _unaryLevel;

  @override
  String get tex => '$prefix${_wrap(operand, _unaryLevel)}';
}

class _Power extends _Node {
  const _Power(this.base, this.exponent);

  final _Node base;
  final _Node exponent;

  @override
  int get level => _powerLevel;

  /// The base is always in braces, so a power of a power stays readable.
  @override
  String get tex => '{${_wrap(base, _atomLevel)}}^{${exponent.tex}}';
}

/// Parenthesizes [node] when it binds looser than [minLevel], see [_paren].
String _wrap(_Node node, int minLevel) =>
    node.level < minLevel ? _paren(node.tex) : node.tex;

/// A recursive descent parser over the tokens of a formula, with the EvalEx
/// precedence: `||`, `&&`, comparisons, `+ -`, `* / %`, unary `- + !`, `^`
/// (right associative), then calls, names, numbers, strings and parentheses.
class _TexParser {
  _TexParser(this._tokens, this._source, this._functions);

  final List<ExpressionToken> _tokens;
  final String _source;

  /// The lower-case names of the functions a call may use.
  final Set<String> _functions;
  int _pos = 0;

  _Node parse() {
    final node = _or();
    if (_pos < _tokens.length) throw const _TexException();
    return node;
  }

  /// The text of the token [offset] places after the current one, or null.
  String? _textAt(int offset) {
    final index = _pos + offset;
    if (index >= _tokens.length) return null;
    return _tokens[index].textIn(_source);
  }

  bool _isOperator(String symbol, [int offset = 0]) {
    final index = _pos + offset;
    return index < _tokens.length &&
        _tokens[index].kind == ExpressionTokenKind.operator &&
        _textAt(offset) == symbol;
  }

  bool _isPunctuation(String symbol) {
    return _pos < _tokens.length &&
        _tokens[_pos].kind == ExpressionTokenKind.punctuation &&
        _textAt(0) == symbol;
  }

  void _expectPunctuation(String symbol) {
    if (!_isPunctuation(symbol)) throw const _TexException();
    _pos++;
  }

  _Node _or() {
    var left = _and();
    while (_isOperator('||')) {
      _pos++;
      left = _Binary('\\lor', _orLevel, left, _and());
    }
    return left;
  }

  _Node _and() {
    var left = _comparison();
    while (_isOperator('&&')) {
      _pos++;
      left = _Binary('\\land', _andLevel, left, _comparison());
    }
    return left;
  }

  _Node _comparison() {
    var left = _additive();
    while (true) {
      final symbol = _comparisonSymbol();
      if (symbol == null) return left;
      final (tex, count) = symbol;
      _pos += count;
      left = _Binary(
        tex,
        _comparisonLevel,
        left,
        _additive(),
        comparison: true,
      );
    }
  }

  /// The LaTeX of the comparison operator at the current token and how many
  /// tokens it takes. `<>` is two tokens, `<` and `>` written next to each
  /// other.
  (String, int)? _comparisonSymbol() {
    if (_pos >= _tokens.length) return null;
    switch (_textAt(0)) {
      case '=' || '==':
        return ('=', 1);
      case '!=':
        return ('\\neq', 1);
      case '<=':
        return ('\\leq', 1);
      case '>=':
        return ('\\geq', 1);
      case '>':
        return ('>', 1);
      case '<':
        final next = _pos + 1 < _tokens.length ? _tokens[_pos + 1] : null;
        final adjacent =
            next != null &&
            next.kind == ExpressionTokenKind.operator &&
            next.start == _tokens[_pos].end &&
            _textAt(1) == '>';
        return adjacent ? ('\\neq', 2) : ('<', 1);
    }
    return null;
  }

  _Node _additive() {
    var left = _multiplicative();
    while (_isOperator('+') || _isOperator('-')) {
      final symbol = _textAt(0)!;
      _pos++;
      left = _Binary(symbol, _additiveLevel, left, _multiplicative());
    }
    return left;
  }

  _Node _multiplicative() {
    var left = _unary();
    while (_isOperator('*') || _isOperator('/') || _isOperator('%')) {
      final symbol = _textAt(0)!;
      _pos++;
      final right = _unary();
      left = switch (symbol) {
        '/' => _Atom('\\frac{${left.tex}}{${right.tex}}'),
        '*' => _Binary('\\cdot', _multiplicativeLevel, left, right),
        _ => _Binary('\\bmod', _multiplicativeLevel, left, right),
      };
    }
    return left;
  }

  _Node _unary() {
    if (_isOperator('-')) {
      _pos++;
      return _Unary('-', _unary());
    }
    if (_isOperator('+')) {
      _pos++;
      return _Unary('+', _unary());
    }
    if (_isOperator('!')) {
      _pos++;
      return _Unary('\\lnot ', _unary());
    }
    return _power();
  }

  _Node _power() {
    final base = _primary();
    if (!_isOperator('^')) return base;
    _pos++;
    return _Power(base, _unary());
  }

  _Node _primary() {
    if (_pos >= _tokens.length) throw const _TexException();
    final token = _tokens[_pos];
    final text = _textAt(0)!;
    switch (token.kind) {
      case ExpressionTokenKind.number:
        _pos++;
        return _Atom(text);
      case ExpressionTokenKind.string:
        _pos++;
        return _Atom(_stringTex(text));
      case ExpressionTokenKind.punctuation:
        if (text != '(') throw const _TexException();
        _pos++;
        final inner = _or();
        _expectPunctuation(')');
        return inner;
      case ExpressionTokenKind.function:
      case ExpressionTokenKind.variable:
      case ExpressionTokenKind.constant:
      case ExpressionTokenKind.unknown:
        if (!_identifier.hasMatch(text)) throw const _TexException();
        _pos++;
        if (_isPunctuation('(')) return _call(text);
        return _Atom(_nameTex(text));
      case ExpressionTokenKind.operator:
      case ExpressionTokenKind.whitespace:
        throw const _TexException();
    }
  }

  _Node _call(String name) {
    final lower = name.toLowerCase();
    if (!_functions.contains(lower)) throw const _TexException();
    _expectPunctuation('(');
    final args = <_Node>[];
    if (!_isPunctuation(')')) {
      args.add(_or());
      while (_isPunctuation(',')) {
        _pos++;
        args.add(_or());
      }
    }
    _expectPunctuation(')');
    final arity = _builtinArity[lower];
    if (arity != null && arity != args.length) throw const _TexException();
    if (_variadicBuiltins.contains(lower) && args.isEmpty) {
      throw const _TexException();
    }
    return _Atom(_callTex(lower, [for (final arg in args) arg.tex]));
  }
}

/// The LaTeX of a call to the function [name] (lower case) with the LaTeX of
/// its [args]. Built-in functions get their own notation, other functions are
/// set as operator names.
String _callTex(String name, List<String> args) {
  final joined = args.join(', ');
  return switch (name) {
    'sqrt' => '\\sqrt{${args[0]}}',
    'abs' => '\\left| ${args[0]} \\right|',
    'floor' => '\\lfloor ${args[0]} \\rfloor',
    'ceiling' => '\\lceil ${args[0]} \\rceil',
    'log' => '\\ln${_paren(args[0])}',
    'log10' => '\\log_{10}${_paren(args[0])}',
    'sin' => '\\sin${_paren(args[0])}',
    'cos' => '\\cos${_paren(args[0])}',
    'tan' => '\\tan${_paren(args[0])}',
    'min' => '\\min${_paren(joined)}',
    'max' => '\\max${_paren(joined)}',
    'if' =>
      '\\begin{cases} ${args[1]} & \\text{if } ${args[0]} \\\\ '
          '${args[2]} & \\text{otherwise} \\end{cases}',
    _ => '\\mathrm{${_escapeUnderscore(name)}}${_paren(joined)}',
  };
}

/// The LaTeX of a name that is not a call: the constants keep their symbol,
/// the other names are set as one word so they do not read as a product.
String _nameTex(String name) => switch (name.toLowerCase()) {
  'pi' => '\\pi',
  'e' => 'e',
  'true' => '\\text{true}',
  'false' => '\\text{false}',
  _ => _variableTex(name),
};

/// The LaTeX of a variable name, set as one word.
String _variableTex(String name) => '\\mathit{${_escapeUnderscore(name)}}';

/// The LaTeX of a string literal, keeping its quotes and escaping the TeX
/// characters in its text.
String _stringTex(String literal) {
  final quote = literal[0];
  final closed = literal.length >= 2 && literal.endsWith(quote);
  if (!closed) throw const _TexException();
  final inner = literal.substring(1, literal.length - 1);
  return '\\text{$quote${_escapeText(inner)}$quote}';
}

String _escapeUnderscore(String name) => name.replaceAll('_', r'\_');

/// Escapes the characters TeX reads as commands or math in plain text.
String _escapeText(String text) {
  final buffer = StringBuffer();
  for (final char in text.split('')) {
    buffer.write(switch (char) {
      r'\' => r'\textbackslash{}',
      '~' => r'\textasciitilde{}',
      '^' => r'\textasciicircum{}',
      '&' || '%' || r'$' || '#' || '_' || '{' || '}' => '\\$char',
      _ => char,
    });
  }
  return buffer.toString();
}

/// Parenthesizes [inner]. Plain parentheses keep the content on the top level,
/// so a long formula can break inside them; `\left(`/`\right)` are only
/// used around tall content such as fractions or cases, where the parentheses
/// have to grow with it.
String _paren(String inner) =>
    inner.contains('\\frac') || inner.contains('\\begin{cases}')
        ? '\\left($inner\\right)'
        : '($inner)';
