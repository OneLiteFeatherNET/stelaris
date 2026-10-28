import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/feature/expression/expression_formula_controller.dart';
import 'package:stelaris/util/app_theme.dart';
import 'package:stelaris_models/stelaris_models.dart';

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

/// The spans [controller] draws, built inside a real theme: the light one
/// unless [theme] is given.
Future<TextSpan> _spans(
  WidgetTester tester,
  ExpressionFormulaController controller, {
  ThemeData? theme,
}) async {
  late TextSpan span;
  await tester.pumpWidget(
    MaterialApp(
      // A fresh app per call, so the builder runs again under this theme.
      key: UniqueKey(),
      theme: theme,
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

  testWidgets(
    'operators, numbers and punctuation use the dark scheme under the dark theme',
    (tester) async {
      final darkTheme = AppTheme.buildDark(ThemeSettings.defaultSettings());
      final lightTheme = AppTheme.buildLight(ThemeSettings.defaultSettings());
      final controller = ExpressionFormulaController(text: 'a * 2 ^ (b)')
        ..setNames(catalog: null, variables: const ['a', 'b']);

      final darkSpan = await _spans(tester, controller, theme: darkTheme);
      final dark = _leaves(darkSpan);
      final darkColors = darkTheme.colorScheme;

      Color? colorOf(List<(String, TextStyle?)> leaves, String text) =>
          leaves.firstWhere((leaf) => leaf.$1 == text).$2?.color;

      expect(
        colorOf(dark, '*'),
        darkColors.onSurface,
        reason: 'the operator * must use the dark onSurface colour',
      );
      expect(
        colorOf(dark, '2'),
        darkColors.tertiary,
        reason: 'the number 2 must use the dark tertiary colour',
      );
      expect(
        colorOf(dark, '('),
        darkColors.onSurfaceVariant,
        reason: 'the punctuation ( must use the dark onSurfaceVariant colour',
      );

      final lightSpan = await _spans(tester, controller, theme: lightTheme);
      expect(
        colorOf(_leaves(lightSpan), '*'),
        isNot(darkColors.onSurface),
        reason: 'the light and dark operator colours must differ',
      );
    },
  );
}
