import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/expression/expression_math_view.dart';
import 'package:stelaris/feature/expression/expression_tex.dart';

Future<void> _pump(
  WidgetTester tester, {
  required String formula,
  required String? tex,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ExpressionMathView(formula: formula, tex: tex, fontSize: 22),
      ),
    ),
  );
}

void main() {
  testWidgets('valid LaTeX is drawn as math', (tester) async {
    await _pump(tester, formula: 'a / b', tex: r'\frac{a}{b}');

    expect(
      find.byType(Math),
      findsOneWidget,
      reason: 'a formula with LaTeX is typeset',
    );
  });

  testWidgets('a formula without LaTeX is shown as its text', (tester) async {
    await _pump(tester, formula: 'a * (', tex: null);

    expect(find.byType(Math), findsNothing);
    expect(find.text('a * ('), findsOneWidget);
  });

  testWidgets('LaTeX that does not render falls back to the formula text', (
    tester,
  ) async {
    await _pump(tester, formula: 'x', tex: r'\undefinedcommand{x}');

    expect(
      find.text('x'),
      findsOneWidget,
      reason: 'the formula text is shown when the LaTeX does not render',
    );
  });

  testWidgets('the formula text fallback is set in monospace', (tester) async {
    await _pump(tester, formula: 'a * (', tex: null);

    final text = tester.widget<Text>(find.text('a * ('));
    expect(text.style?.fontFamily, 'monospace');
  });

  testWidgets('a long formula in a narrow box breaks into several parts', (
    tester,
  ) async {
    const formula = 'alpha + beta + gamma + delta + epsilon + zeta + eta';
    final tex = expressionToTex(formula);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 250,
            child: ExpressionMathView(formula: formula, tex: tex, fontSize: 22),
          ),
        ),
      ),
    );

    expect(
      tester.takeException(),
      isNull,
      reason: 'a formula wider than its box wraps instead of overflowing',
    );
    expect(
      find.byType(Math).evaluate().length,
      greaterThan(1),
      reason: 'the formula is broken after its operators into parts',
    );
    expect(
      find.byType(Wrap),
      findsOneWidget,
      reason: 'the parts are laid out in a wrap',
    );
  });

  testWidgets('a formula without operators is a single part', (tester) async {
    await _pump(tester, formula: 'a / b', tex: r'\frac{a}{b}');

    expect(
      find.byType(Math),
      findsOneWidget,
      reason: 'a fraction has no operator to break after',
    );
  });

  for (final formula in [
    'ROUND(100 * level ^ 1.5, 0)',
    'armor / (armor + 100)',
    'IF(attribute == "strength", 12, 5)',
    'SQRT(ABS(a)) + MAX(a, b) >= 2 && !flag',
    'ROUND((base_damage + attribute_value("strength") * 0.8) * '
        'crit_multiplier(luck) * (1 - armor_reduction(armor)), 2)',
  ]) {
    testWidgets('the converted LaTeX of $formula renders without fallback', (
      tester,
    ) async {
      final tex = expressionToTex(
        formula,
        functionNames: const {
          'attribute_value',
          'crit_multiplier',
          'armor_reduction',
        },
      );
      expect(tex, isNotNull, reason: 'the formula converts to LaTeX');

      await _pump(tester, formula: formula, tex: tex);

      expect(
        find.text(formula),
        findsNothing,
        reason: 'the LaTeX $tex must render, not fall back to the raw text',
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a long function call breaks inside its parentheses', (
    tester,
  ) async {
    final tex = expressionToTex(
      'ROUND((base_damage + attribute_value("strength") * 0.8) * '
      'crit_multiplier(luck) * (1 - armor_reduction(armor)), 2)',
      functionNames: const {
        'attribute_value',
        'crit_multiplier',
        'armor_reduction',
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: ExpressionMathView(formula: 'x', tex: tex, fontSize: 22),
          ),
        ),
      ),
    );

    expect(
      find.byType(Math).evaluate().length,
      greaterThan(1),
      reason: 'the formula wrapped in round(...) must still break into lines',
    );
    expect(tester.takeException(), isNull);
  });
}
