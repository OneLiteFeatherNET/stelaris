import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/item/item_component_actions.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/preview/asset_preview_placeholder.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/item/components/item_components_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_asset_api.dart';
import '../../../support/fake_http_client_adapter.dart';
import '../../../support/pump_until.dart';
import '../../../support/settle_requests.dart';

void main() {
  setUp(() => AssetLibrary.shared.invalidate());

  Future<void> pumpPage(
    WidgetTester tester,
    List<ItemComponentDto> components, {
    Project? project,
    Size size = const Size(1400, 1000),
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Without a selected item the fetch does nothing, so the components
    // stay as given.
    final store = Store<AppState>(
      initialState: const AppState().copyWith(
        selectedItemComponents: components,
        selectedProject: project,
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
    if (settle) await tester.pumpAndSettle();
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

  testWidgets(
    'a component card is outlined like the other cards that open a dialog',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      await pumpPage(tester, const [food]);

      final shape =
          tester
                  .widget<Material>(
                    find
                        .descendant(
                          of: find.ancestor(
                            of: find.text('Food'),
                            matching: find.byType(Card),
                          ),
                          matching: find.byType(Material),
                        )
                        .first,
                  )
                  .shape!
              as RoundedRectangleBorder;
      expect(shape.side.style, BorderStyle.solid);
    },
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
        tester.widget<InkWell>(inCard('Material', find.byType(InkWell))).onTap,
        isNotNull,
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
    'shows the components once the tab settled and keeps them while switching',
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
      // The tab is built once it scrolls into view; it requests after that
      // frame.
      await tester.pump(const Duration(milliseconds: 16));
      // Mid animation: already requested, but still skeleton cards.
      expect(requests, 1);
      expect(find.byKey(const Key('component_skeleton')), findsOneWidget);
      expect(find.text('Food'), findsNothing);

      await settleRequests(
        tester,
        () => store.state.selectedItemComponents.isEmpty,
      );
      expect(requests, 1);
      expect(find.text('Food'), findsOneWidget);

      await tester.tap(find.text('General'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Comp'));
      await tester.pumpAndSettle();
      // Kept alive: shown again without another request.
      expect(requests, 1);
      expect(find.text('Food'), findsOneWidget);

      // Another item loads its own components.
      store.dispatch(
        SelectedItemAction(const ItemModel(id: 'item-2', uiName: 'Bread')),
      );
      await settleRequests(
        tester,
        () => store.isWaiting(ItemComponentFetchAction),
      );
      expect(requests, 2);
      expect(find.text('Food'), findsOneWidget);
    },
  );

  testWidgets(
    'as the tab a page opens on, shows them once the page slid in',
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
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(
                      body: DefaultTabController(
                        length: 1,
                        child: TabBarView(children: [ItemComponentsPage()]),
                      ),
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      // Mid transition: already requested, but still skeleton cards.
      expect(requests, 1);
      expect(find.byKey(const Key('component_skeleton')), findsOneWidget);
      expect(find.text('Food'), findsNothing);

      await settleRequests(
        tester,
        () => store.state.selectedItemComponents.isEmpty,
      );
      expect(requests, 1);
      expect(find.text('Food'), findsOneWidget);
      expect(find.byKey(const Key('component_skeleton')), findsNothing);
    },
  );

  group('item model preview', () {
    const vulpes = Project(id: 'p-1', displayName: 'Vulpes', key: 'vulpes');
    const itemModel = ItemComponentDto(
      id: 'c7',
      componentKey: 'minecraft:item_model',
      value: 'vulpes:item/ruby',
    );
    const narrow = Size(800, 1000);

    Finder toggle() => find.byKey(const Key('item_model_preview_toggle'));
    Finder panel() => find.byKey(const Key('item_model_preview'));
    Finder placeholder() => find.descendant(
      of: panel(),
      matching: find.byType(AssetPreviewPlaceholder),
    );
    Finder card(String name) =>
        find.ancestor(of: find.text(name), matching: find.byType(Card));

    bool toggleEnabled(WidgetTester tester) =>
        tester.widget<PageHeaderAction>(toggle()).onPressed != null;

    /// Waits until the preview has loaded its scene, a spinner would keep
    /// the frames from settling.
    Future<void> pumpUntilPanel(WidgetTester tester) => pumpUntil(
      tester,
      action: () async {},
      done: () => placeholder().evaluate().isNotEmpty,
    );

    testWidgets(
      'shows the model next to the cards when the window is wide',
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      (tester) async {
        serveAssets([
          assetJson(id: 'm-1', key: 'vulpes:item/ruby', kind: 'MODEL'),
        ]);
        await pumpPage(
          tester,
          const [food, itemModel],
          project: vulpes,
          settle: false,
        );
        await pumpUntilPanel(tester);

        expect(placeholder(), findsOneWidget);
        expect(
          find.descendant(of: panel(), matching: find.text('vulpes:item/ruby')),
          findsOneWidget,
        );
        expect(find.byType(BottomSheet), findsNothing);
      },
    );

    testWidgets(
      'keeps the cards as tall as on develop while the preview shows',
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      (tester) async {
        serveAssets([
          assetJson(id: 'm-1', key: 'vulpes:item/ruby', kind: 'MODEL'),
        ]);
        await pumpPage(
          tester,
          const [food, itemModel],
          project: vulpes,
          settle: false,
        );
        await pumpUntilPanel(tester);

        expect(tester.getSize(card('Item Model')).height, 112);
        expect(tester.getSize(card('Food')).height, 112);
      },
    );

    testWidgets(
      'hides the model when the toggle is pressed',
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      (tester) async {
        serveAssets([
          assetJson(id: 'm-1', key: 'vulpes:item/ruby', kind: 'MODEL'),
        ]);
        await pumpPage(
          tester,
          const [food, itemModel],
          project: vulpes,
          settle: false,
        );
        await pumpUntilPanel(tester);

        await tester.tap(toggle());
        await tester.pumpAndSettle();

        expect(panel(), findsNothing);
        expect(card('Food'), findsOneWidget);
      },
    );

    testWidgets(
      'opens the model in a bottom sheet when the window is narrow',
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      (tester) async {
        serveAssets([
          assetJson(id: 'm-1', key: 'vulpes:item/ruby', kind: 'MODEL'),
        ]);
        await pumpPage(
          tester,
          const [food, itemModel],
          project: vulpes,
          size: narrow,
          settle: false,
        );
        await pumpUntil(
          tester,
          action: () async {},
          done: () => toggleEnabled(tester),
        );
        // No room next to the cards, so nothing is shown inline.
        expect(panel(), findsNothing);

        await tester.tap(toggle());
        await pumpUntilPanel(tester);

        expect(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: placeholder(),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'the toggle is disabled without an item model',
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      (tester) async {
        await pumpPage(tester, const [food], project: vulpes);

        expect(toggleEnabled(tester), isFalse);
        expect(panel(), findsNothing);
      },
    );

    testWidgets(
      'the toggle is disabled without a project',
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      (tester) async {
        await pumpPage(tester, const [itemModel]);

        expect(toggleEnabled(tester), isFalse);
        expect(panel(), findsNothing);
      },
    );

    testWidgets(
      'the toggle is disabled when no model has the key',
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      (tester) async {
        serveAssets([
          assetJson(id: 'm-2', key: 'vulpes:item/sapphire', kind: 'MODEL'),
        ]);
        // The lookup is done before the page, so the page only reads it.
        await tester.runAsync(
          () => AssetLibrary.shared.findModelByKey('p-1', 'vulpes:item/ruby'),
        );
        await pumpPage(tester, const [itemModel], project: vulpes);

        expect(toggleEnabled(tester), isFalse);
        expect(panel(), findsNothing);
      },
    );

    testWidgets(
      'a texture with the key of the item model is not previewed as the model',
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      (tester) async {
        serveAssets([
          assetJson(id: 't-1', key: 'vulpes:item/ruby', kind: 'TEXTURE'),
        ]);
        // The lookup is done before the page, so the page only reads it.
        await tester.runAsync(
          () => AssetLibrary.shared.findModelByKey('p-1', 'vulpes:item/ruby'),
        );
        await pumpPage(tester, const [itemModel], project: vulpes);

        expect(toggleEnabled(tester), isFalse);
        expect(panel(), findsNothing);
      },
    );
  });
}
