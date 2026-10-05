import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/item/components/component_dialogs.dart';
import 'package:stelaris/feature/item/components/schema_field.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:vulpes_data/component.dart';

ComponentSpec _spec(String key) =>
    dataComponents.singleWhere((spec) => spec.key == key);

void main() {
  Future<void> pumpOpener(
    WidgetTester tester,
    Future<Object?> Function(BuildContext context) open,
    void Function(Object? result) onResult,
  ) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => onResult(await open(context)),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  test('managed and runtime components are not offered', () {
    final keys = offeredComponents.map((spec) => spec.key).toSet();
    expect(keys, isNot(contains('minecraft:lore')));
    expect(keys, isNot(contains('minecraft:enchantments')));
    expect(keys, isNot(contains('minecraft:custom_name')));
    expect(keys, isNot(contains('minecraft:bundle_contents')));
    expect(keys, contains('minecraft:food'));
  });

  test('initial value only contains required fields', () {
    expect(initialValue(_spec('minecraft:food').schema), {
      'nutrition': 0,
      'saturation': 0.0,
    });
    expect(initialValue(_spec('minecraft:max_stack_size').schema), 1);
    // Components without a value are an empty object in the vanilla format.
    expect(initialValue(_spec('minecraft:glider').schema), <String, Object?>{});
  });

  test('summaries', () {
    expect(
      summarize(_spec('minecraft:dyed_color').schema, 0xFF0000),
      '#FF0000',
    );
    expect(summarize(_spec('minecraft:glider').schema, null), 'Set');
    expect(
      summarize(_spec('minecraft:food').schema, {
        'nutrition': 4,
        'saturation': 2.4,
      }),
      'Nutrition: 4, Saturation: 2.4',
    );
  });

  testWidgets('picker hides existing components and returns the selection', (
    tester,
  ) async {
    Object? picked;
    await pumpOpener(
      tester,
      (context) => showComponentPickerDialog(
        context,
        existing: {'minecraft:tool'},
        materialDefaults: {'minecraft:food'},
      ),
      (result) => picked = result,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(SearchBar), 'foo');
    await tester.pumpAndSettle();
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);

    await tester.enterText(find.byType(SearchBar), 'tool');
    await tester.pumpAndSettle();
    expect(find.text('minecraft:tool'), findsNothing);

    await tester.enterText(find.byType(SearchBar), 'foo');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    expect((picked as ComponentSpec).key, 'minecraft:food');
  });

  testWidgets('picker filters by category through the search', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpOpener(
      tester,
      (context) => showComponentPickerDialog(
        context,
        existing: const {},
        materialDefaults: const {},
      ),
      (_) {},
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final sizeBefore = tester.getSize(find.byType(Dialog));
    final filter = find.byKey(const Key('component_category_filter'));
    bool filterSelected() =>
        tester.widget<IconButton>(filter).isSelected ?? false;
    expect(filterSelected(), isFalse);

    // Clicking a category header filters by it.
    await tester.tap(
      find.byKey(const Key('component_category_header_properties')),
    );
    await tester.pumpAndSettle();
    expect(filterSelected(), isTrue);
    expect(find.text('Search in Properties'), findsOneWidget);
    expect(find.text('minecraft:max_stack_size'), findsOneWidget);
    expect(find.text('minecraft:food'), findsNothing);

    // The filter menu switches to another category and back to all.
    await tester.tap(filter);
    await tester.pumpAndSettle();
    // It leaves out categories without any component.
    final menu = tester.getRect(
      find.byKey(const Key('component_category_item_all')),
    );
    // It has its fixed width and ends where the filter button does.
    expect(menu.width, 260);
    expect(
      menu.right,
      moreOrLessEquals(tester.getRect(filter).right, epsilon: 1),
    );
    expect(
      find.byKey(const Key('component_category_item_other')),
      findsNothing,
    );
    await tester.tap(
      find.byKey(const Key('component_category_item_consumable')),
    );
    await tester.pumpAndSettle();
    expect(find.text('minecraft:food'), findsOneWidget);
    expect(find.text('minecraft:max_stack_size'), findsNothing);

    await tester.tap(filter);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('component_category_item_all')));
    await tester.pumpAndSettle();
    expect(filterSelected(), isFalse);
    // The list starts with properties again; food is too far down to build.
    expect(find.text('minecraft:max_stack_size'), findsOneWidget);

    // The search also matches category names.
    await tester.enterText(find.byType(SearchBar), 'consumable');
    await tester.pumpAndSettle();
    expect(find.text('minecraft:food'), findsOneWidget);

    await tester.enterText(find.byType(SearchBar), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No component matches the search.'), findsOneWidget);
    expect(tester.getSize(find.byType(Dialog)), sizeBefore);
  });

  testWidgets('edit dialog builds the form from the schema', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    ({Object? value})? saved;
    await pumpOpener(
      tester,
      (context) => showComponentEditDialog(
        context,
        spec: _spec('minecraft:food'),
        value: initialValue(_spec('minecraft:food').schema),
      ),
      (result) => saved = result as ({Object? value})?,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nutrition'),
      '6',
    );
    await tester.pump();
    await tester.tap(find.text('Can Always Eat (optional)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved?.value, {
      'nutrition': 6,
      'saturation': 0.0,
      'can_always_eat': false,
    });
  });

  testWidgets('edit dialog requires a key', (tester) async {
    ({Object? value})? saved;
    await pumpOpener(
      tester,
      (context) => showComponentEditDialog(
        context,
        spec: _spec('minecraft:item_model'),
        value: initialValue(_spec('minecraft:item_model').schema),
      ),
      (result) => saved = result as ({Object? value})?,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('A key is required'), findsOneWidget);
    expect(saved, isNull);

    await tester.enterText(find.byType(TextFormField), 'minecraft:stick');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved?.value, 'minecraft:stick');
  });

  testWidgets('edit dialog rejects values out of range', (tester) async {
    ({Object? value})? saved;
    await pumpOpener(
      tester,
      (context) => showComponentEditDialog(
        context,
        spec: _spec('minecraft:max_stack_size'),
        value: 1,
      ),
      (result) => saved = result as ({Object? value})?,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '120');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Between 1 and 99'), findsWidgets);
    expect(saved, isNull);
  });
}
