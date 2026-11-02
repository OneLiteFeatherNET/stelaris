import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/expression/expression_function_sidebar.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

const _e =
    '2.71828182845904523536028747135266249775724709369995957496696762772407663';

const _catalog = ExpressionCatalog(
  functions: [
    CatalogFunction(name: 'ROUND', category: CatalogFunctionCategory.basic),
    CatalogFunction(
      name: 'SIN',
      category: CatalogFunctionCategory.trigonometric,
    ),
  ],
  constants: [CatalogConstant(name: 'E', value: _e)],
);

final _constant = find.byKey(const ValueKey('expression_constant_E'));

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 520,
            height: 600,
            child: ExpressionFunctionSidebar(
              catalog: _catalog,
              onFunction: (_) {},
              onConstant: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a constant with a very long value lays out in a narrow picker', (
    tester,
  ) async {
    await _pump(tester);

    expect(tester.takeException(), isNull);
    expect(_constant, findsOneWidget);
  });
}
