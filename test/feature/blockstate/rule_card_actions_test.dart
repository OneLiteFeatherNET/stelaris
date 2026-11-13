import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/blockstate/block_state_rules.dart';
import 'package:stelaris/feature/blockstate/block_state_rules_tab.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

BlockStateModel _entry(String key) => BlockStateModel(
  id: '1',
  uiName: 'Test',
  key: key,
  rules: const [BlockStateRule(name: 'Seat', model: 'minecraft:block/seat')],
);

/// Shows the rules of [entry] and returns the last entry it reported.
Future<BlockStateModel? Function()> _show(
  WidgetTester tester,
  BlockStateModel entry,
) async {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  BlockStateModel? changed;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlockStateRulesTab(
          entry: entry,
          others: const [],
          onChanged: (entry) => changed = entry,
        ),
      ),
    ),
  );
  return () => changed;
}

void main() {
  group('rule card buttons', () {
    testWidgets('splits the rule into one per facing', (tester) async {
      final changed = await _show(tester, _entry('minecraft:oak_stairs'));

      await tester.tap(find.byTooltip('Split per facing and rotate'));
      await tester.pumpAndSettle();

      final rules = changed()!.rules;
      final facings = specFor('minecraft:oak_stairs').properties['facing']!;
      expect(rules, hasLength(facings.length));
      expect([for (final rule in rules) rule.when['facing']!.single], facings);
    });

    testWidgets('offers no split for a block without a facing', (tester) async {
      await _show(tester, _entry('minecraft:note_block'));

      expect(find.byTooltip('Split per facing and rotate'), findsNothing);
      expect(find.byTooltip('Delete'), findsOneWidget);
    });

    testWidgets('deletes the rule once confirmed', (tester) async {
      final changed = await _show(tester, _entry('minecraft:note_block'));

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      expect(changed(), isNull);

      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(changed()!.rules, isEmpty);
    });
  });
}
