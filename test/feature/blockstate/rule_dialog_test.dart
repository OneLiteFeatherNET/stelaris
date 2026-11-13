import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/blockstate/block_state_rules.dart';
import 'package:stelaris/feature/blockstate/block_state_rules_tab.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

const _spec = BlockSpec('minecraft:oak_stairs', 'Oak stairs', {
  'facing': ['north', 'east', 'south', 'west'],
  'half': ['top', 'bottom'],
  'shape': [
    'straight',
    'inner_left',
    'inner_right',
    'outer_left',
    'outer_right',
  ],
  'waterlogged': ['true', 'false'],
}, {});

/// The rule the last dialog of [_open] popped.
BlockStateRule? _result;

Future<void> _open(WidgetTester tester, Size size) async {
  _result = null;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => _result = await showRuleDialog(
              context,
              title: 'Rule 1',
              spec: _spec,
              rule: const BlockStateRule(model: 'minecraft:block/oak_stairs'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('rule dialog', () {
    testWidgets('puts the condition and the result side by side', (
      tester,
    ) async {
      await _open(tester, const Size(1400, 900));

      final when = tester.getTopLeft(find.text('When'));
      final then = tester.getTopLeft(find.text('Then'));
      expect(then.dx, greaterThan(when.dx));
      expect(then.dy, when.dy);
    });

    testWidgets('keeps the result in view while scrolling the properties', (
      tester,
    ) async {
      await _open(tester, const Size(1400, 800));

      final model = find.text('Model *');
      final before = tester.getTopLeft(model);
      await tester.drag(find.text('north'), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.text('north')).dy, lessThan(before.dy));
      expect(tester.getTopLeft(model), before);
    });

    testWidgets('stacks the condition and the result when narrow', (
      tester,
    ) async {
      await _open(tester, const Size(600, 900));

      final when = tester.getTopLeft(find.text('When'));
      final then = tester.getTopLeft(find.text('Then'));
      expect(then.dx, when.dx);
      expect(then.dy, greaterThan(when.dy));
    });

    testWidgets('a click on a chip rebuilds only that chip', (tester) async {
      await _open(tester, const Size(1400, 900));

      final rebuilt = <Type, int>{};
      debugOnRebuildDirtyWidget = (element, _) => rebuilt.update(
        element.widget.runtimeType,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
      addTearDown(() => debugOnRebuildDirtyWidget = null);
      await tester.tap(find.text('north'));
      await tester.pump();

      // Not the 38 chips of all properties.
      expect(rebuilt[FilterChip], 1);
      expect(rebuilt[TextFormField], isNull);
      expect(
        tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'north')),
        isA<FilterChip>().having((chip) => chip.selected, 'selected', isTrue),
      );
    });

    testWidgets('saves the values, rotation and uvlock picked', (tester) async {
      await _open(tester, const Size(1400, 900));

      await tester.tap(find.text('north'));
      await tester.tap(find.text('top'));
      await tester.tap(find.text('uvlock'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final rule = _result!;
      expect(rule.when['facing'], ['north']);
      expect(rule.when['half'], ['top']);
      expect(rule.uvlock, isTrue);
    });

    testWidgets('a yes or no property is a toggle of any, true and false', (
      tester,
    ) async {
      await _open(tester, const Size(1400, 900));

      expect(find.widgetWithText(FilterChip, 'true'), findsNothing);
      final toggle = find.byType(SegmentedButton<String?>);
      expect(toggle, findsOneWidget);
      expect(tester.widget<SegmentedButton<String?>>(toggle).selected, {null});

      await tester.tap(
        find.descendant(of: toggle, matching: find.text('false')),
      );
      await tester.pump();
      expect(tester.widget<SegmentedButton<String?>>(toggle).selected, {
        'false',
      });
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(_result!.when['waterlogged'], ['false']);
    });
  });
}
