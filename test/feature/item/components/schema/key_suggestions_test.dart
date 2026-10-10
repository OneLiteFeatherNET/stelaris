import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/item/components/schema/schema_field.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:vulpes_data/component.dart';

void main() {
  Future<GlobalKey<FormState>> pumpKeyField(
    WidgetTester tester, {
    required String? registry,
    required List<Object?> changes,
  }) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Form(
            key: formKey,
            child: SchemaField(
              schema: KeySchema(registry: registry),
              value: '',
              onChanged: changes.add,
            ),
          ),
        ),
      ),
    );
    return formKey;
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextFormField), text);
    await tester.pump();
  }

  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  group('item key field', () {
    testWidgets('suggests at most five materials', (tester) async {
      await pumpKeyField(tester, registry: 'item', changes: []);

      await type(tester, 'diamond');

      expect(find.byType(MenuItemButton), findsAtLeastNWidgets(1));
      expect(
        find.byType(MenuItemButton).evaluate().length,
        lessThanOrEqualTo(5),
        reason: 'more than five suggestions are shown',
      );
    });

    testWidgets('shows the key beside the display name', (tester) async {
      await pumpKeyField(tester, registry: 'item', changes: []);

      await type(tester, 'diamond sword');

      expect(find.text('Diamond Sword'), findsOneWidget);
      expect(find.text('minecraft:diamond_sword'), findsOneWidget);
    });

    testWidgets('suggests nothing for an empty input', (tester) async {
      await pumpKeyField(tester, registry: 'item', changes: []);

      await type(tester, '');

      expect(find.byType(MenuItemButton), findsNothing);
    });

    testWidgets('writes the key of a tapped suggestion and reports it', (
      tester,
    ) async {
      final changes = <Object?>[];
      await pumpKeyField(tester, registry: 'item', changes: changes);

      await type(tester, 'diamond sword');
      await tester.tap(find.text('Diamond Sword'));
      // The menu item reports a press after the frame it was tapped in.
      await tester.pumpAndSettle();

      expect(fieldText(tester), 'minecraft:diamond_sword');
      expect(changes.last, 'minecraft:diamond_sword');
      expect(find.byType(MenuItemButton), findsNothing, reason: 'list stays open');
    });

    testWidgets('takes the highlighted suggestion with the keyboard', (
      tester,
    ) async {
      final changes = <Object?>[];
      await pumpKeyField(tester, registry: 'item', changes: changes);

      await type(tester, 'diamond sword');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(fieldText(tester), 'minecraft:diamond_sword');
      expect(changes.last, 'minecraft:diamond_sword');
    });

    testWidgets('keeps free text that matches nothing', (tester) async {
      final changes = <Object?>[];
      final formKey = await pumpKeyField(
        tester,
        registry: 'item',
        changes: changes,
      );

      await type(tester, 'mymod:custom_item');

      expect(find.byType(MenuItemButton), findsNothing);
      expect(changes.last, 'mymod:custom_item');
      expect(formKey.currentState!.validate(), isTrue);
      expect(fieldText(tester), 'mymod:custom_item');
    });

    testWidgets('still validates a missing key', (tester) async {
      final formKey = await pumpKeyField(tester, registry: 'item', changes: []);

      expect(formKey.currentState!.validate(), isFalse);
    });
  });

  group('block key field', () {
    testWidgets('suggests blocks', (tester) async {
      await pumpKeyField(tester, registry: 'block', changes: []);

      await type(tester, 'oak planks');

      expect(find.text('minecraft:oak_planks'), findsOneWidget);
    });

    testWidgets('does not suggest items that are not blocks', (tester) async {
      await pumpKeyField(tester, registry: 'block', changes: []);

      await type(tester, 'sword');

      expect(find.byType(MenuItemButton), findsNothing);
    });
  });

  // Can Break, Can Place On and the rules of Tool take blocks as a registry
  // tag field, whose key list holds block key fields.
  group('block tag field', () {
    Future<void> pumpTagField(WidgetTester tester, Object value) {
      return tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: SchemaField(
                schema: const RegistryTagSchema(registry: 'block'),
                value: value,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('suggests blocks for the entries of its key list', (
      tester,
    ) async {
      await pumpTagField(tester, ['']);

      await type(tester, 'oak planks');

      expect(find.text('minecraft:oak_planks'), findsOneWidget);
    });

    testWidgets('suggests nothing for a tag', (tester) async {
      await pumpTagField(tester, '');

      await type(tester, '#minecraft:logs');

      expect(find.byType(MenuItemButton), findsNothing);
    });
  });

  group('other registries', () {
    testWidgets('show no suggestions', (tester) async {
      await pumpKeyField(tester, registry: 'sound_event', changes: []);

      await type(tester, 'diamond');

      expect(find.byType(MenuItemButton), findsNothing);
    });

    testWidgets('show no suggestions without a registry', (tester) async {
      await pumpKeyField(tester, registry: null, changes: []);

      await type(tester, 'diamond');

      expect(find.byType(MenuItemButton), findsNothing);
    });
  });
}
