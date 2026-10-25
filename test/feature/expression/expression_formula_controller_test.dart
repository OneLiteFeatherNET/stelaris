import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/api/model/expression_validation_model.dart';
import 'package:stelaris/feature/expression/expression_formula_controller.dart';

const _catalog = ExpressionCatalog(
  constants: [CatalogConstant(name: 'PI', value: '3.14159')],
);

/// The text of every leaf span of [span], in order, with its style.
List<(String, TextStyle?)> _leaves(TextSpan span) {
  final leaves = <(String, TextStyle?)>[];
  void walk(InlineSpan node) {
    if (node is! TextSpan) return;
    if (node.text != null) leaves.add((node.text!, node.style));
    for (final child in node.children ?? const <InlineSpan>[]) {
      walk(child);
    }
  }

  walk(span);
  return leaves;
}

/// The spans [controller] draws, built inside a real theme.
Future<TextSpan> _spans(
  WidgetTester tester,
  ExpressionFormulaController controller,
) async {
  late TextSpan span;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          span = controller.buildTextSpan(
            context: context,
            withComposing: false,
          );
          return const SizedBox();
        },
      ),
    ),
  );
  return span;
}

ExpressionValidation _check({
  List<ExpressionValidationError> errors = const [],
  List<String> undefined = const [],
}) => ExpressionValidation(
  valid: errors.isEmpty,
  errors: errors,
  undefinedVariables: undefined,
);

Color _errorColor(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(SizedBox))).colorScheme.error;

void main() {
  testWidgets(
    'an error range is underlined in wavy error color over its text',
    (tester) async {
      final controller = ExpressionFormulaController(text: 'a + b')
        ..setNames(
          catalog: null,
          variables: const [],
          validation: _check(
            errors: const [
              ExpressionValidationError(message: 'bad', start: 4, end: 5),
            ],
          ),
        );

      final span = await _spans(tester, controller);
      final underlined = _leaves(span)
          .where((leaf) => leaf.$2?.decoration == TextDecoration.underline)
          .toList();

      expect(underlined.map((leaf) => leaf.$1), ['b']);
      expect(underlined.single.$2!.decorationStyle, TextDecorationStyle.wavy);
      expect(underlined.single.$2!.decorationColor, _errorColor(tester));
    },
  );

  testWidgets('the text next to an error range is not underlined', (
    tester,
  ) async {
    final controller = ExpressionFormulaController(text: 'a + b')
      ..setNames(
        catalog: null,
        variables: const [],
        validation: _check(
          errors: const [
            ExpressionValidationError(message: 'bad', start: 4, end: 5),
          ],
        ),
      );

    final span = await _spans(tester, controller);
    final plain = _leaves(span)
        .where((leaf) => leaf.$2?.decoration != TextDecoration.underline);

    expect(plain.map((leaf) => leaf.$1).join(), 'a + ');
  });

  testWidgets('an error range outside the text is ignored', (tester) async {
    final controller = ExpressionFormulaController(text: 'a + b')
      ..setNames(
        catalog: null,
        variables: const [],
        validation: _check(
          errors: const [
            ExpressionValidationError(message: 'bad', start: 10, end: 12),
          ],
        ),
      );

    final span = await _spans(tester, controller);

    expect(
      _leaves(span)
          .any((leaf) => leaf.$2?.decoration == TextDecoration.underline),
      isFalse,
    );
  });

  testWidgets('without a check the text has no underline', (tester) async {
    final controller = ExpressionFormulaController(text: 'a + b')
      ..setNames(catalog: null, variables: const ['a']);

    final span = await _spans(tester, controller);

    expect(
      _leaves(span)
          .any((leaf) => leaf.$2?.decoration == TextDecoration.underline),
      isFalse,
    );
  });

  testWidgets('an identifier reported undefined is drawn in the error color', (
    tester,
  ) async {
    final controller = ExpressionFormulaController(text: 'PI * 2')
      ..setNames(
        catalog: _catalog,
        variables: const [],
        validation: _check(undefined: const ['pi']),
      );

    final span = await _spans(tester, controller);
    final pi = _leaves(span).firstWhere((leaf) => leaf.$1 == 'PI');

    expect(pi.$2?.color, _errorColor(tester));
  });
}
