import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/item/components/item_components_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester,
    List<ItemComponentDto> components,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Without a selected item the fetch does nothing, so the components
    // stay as given.
    final store = Store<AppState>(
      initialState: const AppState().copyWith(
        selectedItemComponents: components,
      ),
    );
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ItemComponentsPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const food = ItemComponentDto(
    id: 'c1',
    componentKey: 'minecraft:food',
    value: {'nutrition': 4, 'saturation': 2.4},
  );
  const stackSize = ItemComponentDto(
    id: 'c2',
    componentKey: 'minecraft:max_stack_size',
    value: 16,
  );

  // The cards are laid out for the compact density of desktop browsers; the
  // default Android density of tests makes them 2px too tall.
  testWidgets(
    'filters the components by category',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      await pumpPage(tester, const [food, stackSize]);
      final filter = find.byKey(const Key('component_category_filter'));
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Max Stack Size'), findsOneWidget);

      // Only the categories the item has are offered.
      await tester.tap(filter);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('component_category_item_combat')),
        findsNothing,
      );
      await tester.tap(
        find.byKey(const Key('component_category_item_consumable')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Max Stack Size'), findsNothing);
      // The button names the category it filters by.
      expect(
        find.descendant(of: filter, matching: find.text('Consumable')),
        findsOneWidget,
      );
      // The title still counts every component of the item.
      expect(find.text('Components (2)'), findsOneWidget);
    },
  );

  testWidgets('has no category filter without components', (tester) async {
    await pumpPage(tester, const []);
    expect(find.byKey(const Key('component_category_filter')), findsNothing);
  });
}
