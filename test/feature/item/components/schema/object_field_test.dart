import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/item/components/schema/schema_field.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:vulpes_data/component.dart';

const _schema = ObjectSchema({
  'slot': ComponentField('Slot', EnumSchema(['head', 'chest'])),
  'equip_sound': ComponentField(
    'Equip Sound',
    KeySchema(registry: 'sound_event'),
    optional: true,
  ),
  'dispensable': ComponentField('Dispensable', BoolSchema(), optional: true),
  'damage_reduction': ComponentField(
    'Damage Reduction',
    FloatSchema(),
    optional: true,
  ),
});

void main() {
  Future<List<Object?>> pumpObject(
    WidgetTester tester,
    Map<String, Object?> value,
  ) async {
    final changes = <Object?>[];
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SchemaField(
              schema: _schema,
              value: value,
              onChanged: (next) => setState(() {
                changes.add(next);
                value = next! as Map<String, Object?>;
              }),
            ),
          ),
        ),
      ),
    );
    return changes;
  }

  Finder chip(String name) => find.byKey(Key('component_add_field_$name'));
  Finder remove(String name) => find.byKey(Key('component_remove_field_$name'));

  testWidgets('optional fields that are not set wait as chips', (tester) async {
    await pumpObject(tester, {'slot': 'head'});

    expect(find.text('Slot'), findsOneWidget);
    expect(find.text('More fields'), findsOneWidget);
    for (final name in ['equip_sound', 'dispensable', 'damage_reduction']) {
      expect(chip(name), findsOneWidget, reason: name);
      expect(remove(name), findsNothing, reason: name);
    }
    expect(find.byType(CheckboxListTile), findsNothing);
  });

  testWidgets('a chip adds its field with its start value', (tester) async {
    final changes = await pumpObject(tester, {'slot': 'head'});

    await tester.tap(chip('dispensable'));
    await tester.pump();

    expect(changes.last, {'slot': 'head', 'dispensable': false});
    expect(chip('dispensable'), findsNothing);
    expect(find.widgetWithText(SwitchListTile, 'Dispensable'), findsOneWidget);
    expect(remove('dispensable'), findsOneWidget);
  });

  testWidgets('the remove button takes the field out again', (tester) async {
    final changes = await pumpObject(tester, {
      'slot': 'head',
      'equip_sound': 'minecraft:item.armor.equip_iron',
    });

    await tester.tap(remove('equip_sound'));
    await tester.pump();

    expect(changes.last, {'slot': 'head'});
    expect(chip('equip_sound'), findsOneWidget);
  });

  testWidgets('a single line input shows the remove button inside', (
    tester,
  ) async {
    await pumpObject(tester, {'slot': 'head', 'damage_reduction': 0.5});

    expect(
      find.descendant(
        of: find.byType(TextField),
        matching: remove('damage_reduction'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('without missing fields there are no chips', (tester) async {
    await pumpObject(tester, {
      'slot': 'head',
      'equip_sound': 'minecraft:a',
      'dispensable': true,
      'damage_reduction': 1.0,
    });

    expect(find.text('More fields'), findsNothing);
  });
}
