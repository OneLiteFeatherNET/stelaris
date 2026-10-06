import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/item/components/component_dialogs.dart';
import 'package:stelaris/feature/item/components/schema/schema.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/feature/item/components/stelaris_components.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:vulpes_data/component.dart';

ComponentSpec _spec(String key) =>
    componentCatalog.singleWhere((spec) => spec.key == key);

final l10n = lookupAppLocalizations(const Locale('en'));

/// The block predicates as the catalog describes them once the blocks are a
/// registry tag, a list of keys or a single `#tag`.
const _tagPredicates = ComponentSpec(
  'minecraft:can_break',
  'Can Break',
  ComponentCategory.tool,
  'CAN_BREAK',
  ListSchema(
    ObjectSchema({
      'blocks': ComponentField('Blocks', RegistryTagSchema(registry: 'block')),
    }),
  ),
);

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

  test('the stelaris components come first and the material is required', () {
    expect(componentCatalog.take(2).map((spec) => spec.key), [
      'stelaris:material',
      'stelaris:amount',
    ]);
    expect(stelarisComponents.map((spec) => spec.category).toSet(), {
      ComponentCategory.custom,
    });
    expect(_spec('stelaris:material').isRequired, isTrue);
    expect(_spec('stelaris:amount').isRequired, isFalse);
    expect(_spec('minecraft:food').isRequired, isFalse);
  });

  test('the material is read from its component', () {
    expect(materialOf(const []), 'minecraft:dirt');
    expect(
      materialOf(const [
        ItemComponentDto(
          id: 'c1',
          componentKey: 'minecraft:food',
          value: <String, Object?>{},
        ),
        ItemComponentDto(
          id: 'c2',
          componentKey: 'stelaris:material',
          value: 'minecraft:stone',
        ),
      ]),
      'minecraft:stone',
    );
    // A value which isn't a key falls back to the default.
    expect(
      materialOf(const [
        ItemComponentDto(id: 'c3', componentKey: 'stelaris:material', value: 5),
      ]),
      'minecraft:dirt',
    );
  });

  test('dedicated and runtime components are not offered', () {
    final keys = offeredComponents.map((spec) => spec.key).toSet();
    expect(keys.intersection(dedicatedComponents), isEmpty);
    expect(dedicatedComponents, {'minecraft:lore', 'minecraft:enchantments'});
    // Plain components now, the backend accepts them.
    expect(keys, containsAll(['minecraft:custom_name', 'minecraft:item_name']));
    expect(keys, containsAll(['stelaris:material', 'stelaris:amount']));
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

  test('registry tags start as an empty list and summarize both forms', () {
    const tag = RegistryTagSchema(registry: 'block');
    expect(initialValue(tag), <Object?>[]);
    expect(
      summarize(l10n, tag, ['minecraft:stone', 'minecraft:dirt']),
      '2 entries',
    );
    expect(summarize(l10n, tag, '#minecraft:logs'), '#minecraft:logs');
    expect(
      summarize(l10n, _tagPredicates.schema, [
        {'blocks': '#minecraft:logs'},
      ]),
      '#minecraft:logs',
    );
    expect(
      summarize(l10n, _tagPredicates.schema, [
        {
          'blocks': ['minecraft:stone'],
        },
        {
          'blocks': ['minecraft:dirt', 'minecraft:sand'],
        },
      ]),
      '3 entries',
    );
    // A tag can't be joined with the keys of another entry, so the entries stay.
    expect(
      summarize(l10n, _tagPredicates.schema, [
        {'blocks': '#minecraft:logs'},
        {
          'blocks': ['minecraft:stone'],
        },
      ]),
      '2 entries',
    );
  });

  test('summaries', () {
    expect(
      summarize(l10n, _spec('minecraft:dyed_color').schema, 0xFF0000),
      '#FF0000',
    );
    expect(summarize(l10n, _spec('minecraft:glider').schema, null), 'Set');
    expect(
      summarize(l10n, _spec('minecraft:food').schema, {
        'nutrition': 4,
        'saturation': 2.4,
      }),
      'Nutrition: 4, Saturation: 2.4',
    );
    expect(
      summarize(l10n, _spec('minecraft:can_break').schema, [
        {
          'blocks': ['minecraft:dirt'],
        },
        {
          'blocks': ['minecraft:stone', 'minecraft:sand'],
        },
      ]),
      '3 entries',
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

  testWidgets('picker lists the custom components first', (tester) async {
    await pumpOpener(
      tester,
      (context) => showComponentPickerDialog(
        context,
        existing: {'stelaris:material'},
        materialDefaults: const {},
      ),
      (_) {},
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final custom = find.byKey(const Key('component_category_header_custom'));
    final properties = find.byKey(
      const Key('component_category_header_properties'),
    );
    expect(custom, findsOneWidget);
    expect(
      tester.getTopLeft(custom).dy,
      lessThan(tester.getTopLeft(properties).dy),
    );
    expect(find.text('Amount'), findsOneWidget);
    // The item has its material already.
    expect(find.text('stelaris:material'), findsNothing);
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
    // The list starts with the custom components again; food is too far down
    // to build.
    expect(find.text('stelaris:material'), findsOneWidget);

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
        onSave: (value) async {
          saved = (value: value);
          return null;
        },
      ),
      (_) {},
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

  testWidgets('edits the block predicates as one list of blocks', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    ({Object? value})? saved;
    await pumpOpener(
      tester,
      (context) => showComponentEditDialog(
        context,
        spec: _spec('minecraft:can_break'),
        value: [
          {
            'blocks': ['minecraft:dirt'],
          },
          {
            'blocks': ['minecraft:stone'],
          },
        ],
        onSave: (value) async {
          saved = (value: value);
          return null;
        },
      ),
      (_) {},
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // One list of both blocks, no frame for the entries around it.
    expect(find.text('Blocks (2)'), findsOneWidget);
    expect(find.textContaining('Entries'), findsNothing);

    await tester.tap(find.byTooltip('Remove entry').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved?.value, [
      {
        'blocks': ['minecraft:stone'],
      },
    ]);
  });

  testWidgets('switches the blocks of a predicate between keys and a tag', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    ({Object? value})? saved;
    await pumpOpener(
      tester,
      (context) => showComponentEditDialog(
        context,
        spec: _tagPredicates,
        value: [
          {
            'blocks': ['minecraft:dirt'],
          },
        ],
        onSave: (value) async {
          saved = (value: value);
          return null;
        },
      ),
      (_) {},
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Still one level: the keys of the only entry, no frame for the entries.
    expect(find.text('Blocks (1)'), findsOneWidget);
    expect(find.textContaining('Entries'), findsNothing);

    await tester.tap(find.text('Tag'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('A tag is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'minecraft:logs');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Expected a tag like #minecraft:logs'), findsOneWidget);
    expect(saved, isNull);

    await tester.enterText(find.byType(TextFormField), '#minecraft:logs');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved?.value, [
      {'blocks': '#minecraft:logs'},
    ]);
  });

  testWidgets('switching a tag back to keys starts an empty list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    ({Object? value})? saved;
    await pumpOpener(
      tester,
      (context) => showComponentEditDialog(
        context,
        spec: _tagPredicates,
        value: [
          {'blocks': '#minecraft:logs'},
        ],
        onSave: (value) async {
          saved = (value: value);
          return null;
        },
      ),
      (_) {},
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('#minecraft:logs'), findsOneWidget);
    await tester.tap(find.text('Keys'));
    await tester.pumpAndSettle();
    expect(find.text('Blocks (0)'), findsOneWidget);

    await tester.tap(find.byTooltip('Add entry'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'minecraft:stone');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved?.value, [
      {
        'blocks': ['minecraft:stone'],
      },
    ]);
  });

  testWidgets('edit dialog requires a key', (tester) async {
    ({Object? value})? saved;
    await pumpOpener(
      tester,
      (context) => showComponentEditDialog(
        context,
        spec: _spec('minecraft:item_model'),
        value: initialValue(_spec('minecraft:item_model').schema),
        onSave: (value) async {
          saved = (value: value);
          return null;
        },
      ),
      (_) {},
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
        onSave: (value) async {
          saved = (value: value);
          return null;
        },
      ),
      (_) {},
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '120');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Between 1 and 99'), findsWidgets);
    expect(saved, isNull);
  });

  testWidgets('edit dialog waits for the save and stays open on an error', (
    tester,
  ) async {
    final save = Completer<Object?>();
    var saves = 0;
    bool? saved;
    await pumpOpener(
      tester,
      (context) => showComponentEditDialog(
        context,
        spec: _spec('minecraft:max_stack_size'),
        value: 16,
        onSave: (_) {
          saves++;
          return save.future;
        },
      ),
      (result) => saved = result as bool?,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pump();
    // While saving, a second click does nothing.
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(saves, 1);

    save.complete('Backend down');
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Backend down'), findsOneWidget);
    expect(saved, isNull);
  });
}
