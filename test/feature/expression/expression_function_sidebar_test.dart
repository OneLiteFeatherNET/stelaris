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

final _search = find.byKey(const ValueKey('expression_function_search'));
final _filter = find.byKey(const Key('expression_group_filter'));
final _round = find.byKey(const ValueKey('expression_function_ROUND'));
final _sin = find.byKey(const ValueKey('expression_function_SIN'));
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

bool _filterSelected(WidgetTester tester) =>
    tester.widget<IconButton>(_filter).isSelected ?? false;

void main() {
  testWidgets('a constant with a very long value lays out in a narrow picker', (
    tester,
  ) async {
    await _pump(tester);

    expect(tester.takeException(), isNull);
    expect(_constant, findsOneWidget);
  });

  testWidgets('clicking a group header shows only that group', (tester) async {
    await _pump(tester);
    expect(_filterSelected(tester), isFalse);

    await tester.tap(find.byKey(const Key('expression_group_header_basic')));
    await tester.pumpAndSettle();

    expect(_round, findsOneWidget);
    expect(_sin, findsNothing);
    expect(_constant, findsNothing);
    expect(_filterSelected(tester), isTrue);
  });

  testWidgets('the filter menu picks a group and shows all again', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(_filter);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('expression_group_item_constants')));
    await tester.pumpAndSettle();

    expect(_constant, findsOneWidget);
    expect(_round, findsNothing);

    await tester.tap(_filter);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('expression_group_item_all')));
    await tester.pumpAndSettle();

    expect(_round, findsOneWidget);
    expect(_sin, findsOneWidget);
    expect(_constant, findsOneWidget);
    expect(_filterSelected(tester), isFalse);
  });

  testWidgets('the search matches the name of a group', (tester) async {
    await _pump(tester);

    await tester.enterText(_search, 'trigono');
    await tester.pumpAndSettle();

    expect(_sin, findsOneWidget);
    expect(_round, findsNothing);
  });
}
