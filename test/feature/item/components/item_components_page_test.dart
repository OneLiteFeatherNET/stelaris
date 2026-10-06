import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/item/components/item_components_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

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

  testWidgets(
    'marks the custom components and keeps the material',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      const material = ItemComponentDto(
        id: 'c3',
        componentKey: 'stelaris:material',
        value: 'minecraft:stone',
      );
      const amount = ItemComponentDto(
        id: 'c4',
        componentKey: 'stelaris:amount',
        value: 5,
      );
      await pumpPage(tester, const [food, material, amount]);

      Finder card(String name) =>
          find.ancestor(of: find.text(name), matching: find.byType(Card));
      Finder inCard(String name, Finder finder) =>
          find.descendant(of: card(name), matching: finder);

      // The material can be edited but not removed, every item has one.
      expect(
        inCard('Material', find.byKey(const Key('component_card_remove'))),
        findsNothing,
      );
      expect(
        inCard('Material', find.byKey(const Key('component_card_edit'))),
        findsOneWidget,
      );
      expect(
        inCard('Amount', find.byKey(const Key('component_card_remove'))),
        findsOneWidget,
      );
      expect(
        inCard('Food', find.byKey(const Key('component_card_remove'))),
        findsOneWidget,
      );

      // The custom components name their category in the primary color.
      final context = tester.element(find.text('Material'));
      final primary = Theme.of(context).colorScheme.primary;
      Color? subtitleColor(String name) => tester
          .widget<Text>(
            inCard(name, find.text(name == 'Food' ? 'Consumable' : 'Custom')),
          )
          .style
          ?.color;
      expect(subtitleColor('Material'), primary);
      expect(subtitleColor('Amount'), primary);
      expect(subtitleColor('Food'), isNot(primary));
    },
  );

  const maxDamage = ItemComponentDto(
    id: 'c5',
    componentKey: 'minecraft:max_damage',
    value: 100,
  );
  ItemComponentDto material(String key) =>
      ItemComponentDto(id: 'c6', componentKey: 'stelaris:material', value: key);

  testWidgets(
    'marks a component the material has by default',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      await pumpPage(tester, [material('minecraft:diamond_sword'), maxDamage]);
      expect(find.text('Properties · overrides the default'), findsOneWidget);
    },
  );

  testWidgets(
    "doesn't mark a component the material doesn't have",
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      await pumpPage(tester, [material('minecraft:stone'), maxDamage]);
      expect(find.text('Properties · overrides the default'), findsNothing);
      expect(find.text('Properties'), findsOneWidget);
    },
  );

  testWidgets('has no category filter without components', (tester) async {
    await pumpPage(tester, const []);
    expect(find.byKey(const Key('component_category_filter')), findsNothing);
  });

  testWidgets(
    'loads once the tab settled and keeps the components while switching',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var requests = 0;
      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            requests++;
            return ResponseBody.fromString(
              jsonEncode({
                'items': [food.toJson()],
                'totalItems': 1,
                'totalPages': 1,
                'currentPage': 0,
                'pageSize': 100,
              }),
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          });
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedItem: const ItemModel(id: 'item-1', uiName: 'Apple'),
        ),
      );
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: 'General'),
                        Tab(text: 'Comp'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [Text('general'), ItemComponentsPage()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Comp'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      // Mid animation: a spinner, nothing requested yet.
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(requests, 0);

      await tester.pumpAndSettle();
      expect(requests, 1);
      expect(find.text('Food'), findsOneWidget);

      await tester.tap(find.text('General'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Comp'));
      await tester.pumpAndSettle();
      // Kept alive: shown again without another request.
      expect(requests, 1);
      expect(find.text('Food'), findsOneWidget);
    },
  );
}
