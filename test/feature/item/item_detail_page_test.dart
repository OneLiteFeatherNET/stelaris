import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_page.dart';
import 'package:stelaris/feature/item/general/item_general_page.dart';
import 'package:stelaris/feature/item/general/item_group_card.dart';
import 'package:stelaris/feature/item/item_detail_page.dart';
import 'package:stelaris/feature/item/components/item_components_page.dart';
import 'package:stelaris/feature/item/lore/lore_page.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/recording_http_client_adapter.dart';

void main() {
  group('ItemDetailPage', () {
    const selected = ItemModel(id: 'item-1', uiName: 'Ruby Sword');

    late Store<AppState> store;

    Future<void> pumpPage(
      WidgetTester tester, {
      String location = '/items/detail',
    }) async {
      store = Store<AppState>(
        initialState: const AppState(selectedItem: selected),
      );

      final router = GoRouter(
        initialLocation: location,
        routes: [
          GoRoute(
            path: '/items',
            builder: (context, state) =>
                const Scaffold(body: Text('Item List')),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) => const ItemDetailPage(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows the back arrow with the item name above the tabs', (
      tester,
    ) async {
      await pumpPage(tester);

      expect(find.byType(PageHeader), findsOneWidget);
      expect(find.text('Ruby Sword'), findsOneWidget);

      final backBarPosition = tester.getTopLeft(find.byType(PageHeader));
      final tabBarPosition = tester.getTopLeft(find.byType(TabBar));
      expect(backBarPosition.dy, lessThan(tabBarPosition.dy));

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.tabs.map((tab) => (tab as Tab).text), [
        'General',
        'Enchantments',
        'Lore',
        'Components',
      ]);
    });

    testWidgets(
      'wires the tab views to General, Enchantments, Lore and Components pages',
      (tester) async {
        await pumpPage(tester);

        final tabBarView = tester.widget<TabBarView>(find.byType(TabBarView));
        expect(tabBarView.children.map((w) => w.runtimeType), [
          ItemGeneralPage,
          ItemEnchantmentPage,
          LorePage,
          ItemComponentsPage,
        ]);
      },
    );

    testWidgets('tapping back navigates to the item list', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('page_header_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('Item List'), findsOneWidget);
    });

    testWidgets('shows info, delete and save in the header', (tester) async {
      await pumpPage(tester);

      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    FilledButton saveButton(WidgetTester tester) => tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Save'),
        matching: find.bySubtype<FilledButton>(),
      ),
    );

    /// Changes the group on the General tab, its only field, and confirms
    /// that the enchantments are reset.
    Future<void> chooseArmorGroup(WidgetTester tester) async {
      await tester.tap(
        find.descendant(
          of: find.byType(ItemGeneralPage),
          matching: find.text('Meta'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Armor').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
    }

    testWidgets('the General tab only edits the group', (tester) async {
      await pumpPage(tester);
      final general = find.byType(ItemGeneralPage);
      expect(
        find.descendant(of: general, matching: find.byType(ItemGroupCard)),
        findsOneWidget,
      );
      // Material, amount, name and model data are components now.
      expect(
        find.descendant(of: general, matching: find.byType(TextFormField)),
        findsNothing,
      );
    });

    testWidgets('changing the group marks the item unsaved right away', (
      tester,
    ) async {
      await pumpPage(tester);
      expect(saveButton(tester).onPressed, isNull);

      await chooseArmorGroup(tester);

      expect(store.state.unsavedChanges, NavigationEntry.items);
      expect(saveButton(tester).onPressed, isNotNull);
    });

    testWidgets('save sends the changed item', (tester) async {
      final adapter = RecordingHttpClientAdapter({
        'id': 'item-1',
        'uiName': 'Ruby Sword',
        'groupName': 'armor',
      });
      ApiService().itemApi.apiClient.dio.httpClientAdapter = adapter;
      await pumpPage(tester);

      await chooseArmorGroup(tester);
      await tester.tap(find.text('Save'));
      // On the web, dio finishes even a faked request in several real-async
      // steps that testWidgets' fake-async zone doesn't run on its own, so
      // alternate frames with a little real time until the save has landed.
      for (var i = 0; i < 20 && store.state.unsavedChanges != null; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
      }
      await tester.pumpAndSettle();

      expect((adapter.lastRequest!.data as Map)['groupName'], 'armor');
      expect(store.state.unsavedChanges, isNull);
    });

    testWidgets('deleting from the header returns to the list without '
        'breaking the page while it slides out', (tester) async {
      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          RecordingHttpClientAdapter({'id': 'item-1', 'uiName': 'Ruby Sword'});
      await pumpPage(tester);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Ruby Sword');
      await tester.pump();
      await tester.tap(find.text('Delete').last);

      // Step through the exit transition, while the DELETE request
      // completes and the detail page is still on screen.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();

      expect(find.text('Item List'), findsOneWidget);
    });

    testWidgets('an old ?tab=meta link opens on General', (tester) async {
      await pumpPage(tester, location: '/items/detail?tab=meta');

      expect(
        DefaultTabController.of(tester.element(find.byType(TabBar))).index,
        0,
      );
    });
  });
}
