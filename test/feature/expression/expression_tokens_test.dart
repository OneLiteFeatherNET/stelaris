import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/feature/expression/expression_tokens.dart';

const _catalog = ExpressionCatalog(
  functions: [CatalogFunction(name: 'ROUND')],
  constants: [CatalogConstant(name: 'PI')],
);

/// The kind and text of each token of [text].
List<(ExpressionTokenKind, String)> _tokens(
  String text, {
  ExpressionCatalog? catalog,
  List<String> variables = const [],
}) => [
  for (final token in tokenizeFormula(
    text,
    catalog: catalog,
    variables: variables,
  ))
    (token.kind, token.textIn(text)),
];

void main() {
  test('a decimal number is one number token', () {
    expect(_tokens('3.25'), [(ExpressionTokenKind.number, '3.25')]);
  });

  test('a number may start with a point', () {
    expect(_tokens('.5'), [(ExpressionTokenKind.number, '.5')]);
  });

  test('a string in double quotes is one string token', () {
    expect(_tokens('"a b"'), [(ExpressionTokenKind.string, '"a b"')]);
  });

  test('a string in single quotes is one string token', () {
    expect(_tokens("'a b'"), [(ExpressionTokenKind.string, "'a b'")]);
  });

  test('an unterminated string runs to the end of the text', () {
    expect(_tokens('"abc + 1'), [(ExpressionTokenKind.string, '"abc + 1')]);
  });

  test(
    'a name followed by a parenthesis is a function when the catalog has it',
    () {
      expect(_tokens('ROUND(x)', catalog: _catalog), [
        (ExpressionTokenKind.function, 'ROUND'),
        (ExpressionTokenKind.punctuation, '('),
        (ExpressionTokenKind.unknown, 'x'),
        (ExpressionTokenKind.punctuation, ')'),
      ]);
    },
  );

  test('a function name is matched ignoring case', () {
    expect(_tokens('round (1)', catalog: _catalog).first, (
      ExpressionTokenKind.function,
      'round',
    ));
  });

  test('a declared variable is a variable, ignoring case', () {
    expect(_tokens('Radius', variables: const ['radius']), [
      (ExpressionTokenKind.variable, 'Radius'),
    ]);
  });

  test('a catalog constant is a constant, ignoring case', () {
    expect(_tokens('pi', catalog: _catalog), [
      (ExpressionTokenKind.constant, 'pi'),
    ]);
  });

  test('a name that is none of the above is unknown', () {
    expect(_tokens('foo', catalog: _catalog, variables: const ['bar']), [
      (ExpressionTokenKind.unknown, 'foo'),
    ]);
  });

  test('a call of a name the catalog lacks is unknown', () {
    expect(_tokens('SQRT(2)', catalog: _catalog).first, (
      ExpressionTokenKind.unknown,
      'SQRT',
    ));
  });

  test('a two-character operator is one operator token', () {
    expect(_tokens('a && b >= 1', variables: const ['a', 'b']), [
      (ExpressionTokenKind.variable, 'a'),
      (ExpressionTokenKind.whitespace, ' '),
      (ExpressionTokenKind.operator, '&&'),
      (ExpressionTokenKind.whitespace, ' '),
      (ExpressionTokenKind.variable, 'b'),
      (ExpressionTokenKind.whitespace, ' '),
      (ExpressionTokenKind.operator, '>='),
      (ExpressionTokenKind.whitespace, ' '),
      (ExpressionTokenKind.number, '1'),
    ]);
  });

  test('a run of spaces and line breaks is one whitespace token', () {
    expect(_tokens('1 \n 2'), [
      (ExpressionTokenKind.number, '1'),
      (ExpressionTokenKind.whitespace, ' \n '),
      (ExpressionTokenKind.number, '2'),
    ]);
  });

  test('the tokens cover the whole text without gaps', () {
    const text = 'max(a, "x") >= 2.5e3 && !b';
    final tokens = tokenizeFormula(text, variables: const ['a', 'b']);

    expect(tokens.first.start, 0);
    expect(tokens.last.end, text.length);
    for (var i = 1; i < tokens.length; i++) {
      expect(tokens[i].start, tokens[i - 1].end, reason: 'token $i');
    }
  });
}
