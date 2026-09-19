import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_page.dart';
import 'package:stelaris/feature/item/general/item_general_page.dart';
import 'package:stelaris/feature/item/item_detail_page.dart';
import 'package:stelaris/feature/item/lore/lore_page.dart';
import 'package:stelaris/feature/item/meta/item_meta_page.dart';
import 'package:stelaris/feature/model/model_detail_back_bar.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('ItemDetailPage', () {
    const selected = ItemModel(id: 'item-1', uiName: 'Ruby Sword');

    Future<void> pumpPage(WidgetTester tester) async {
      final store = Store<AppState>(
        initialState: const AppState(selectedItem: selected),
      );

      final router = GoRouter(
        initialLocation: '/items/detail',
        routes: [
          GoRoute(
            path: '/items',
            builder: (context, state) => const Scaffold(body: Text('Item List')),
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

    testWidgets(
      'shows the back arrow with the item name above the tabs',
      (tester) async {
        await pumpPage(tester);

        expect(find.byType(ModelDetailBackBar), findsOneWidget);
        expect(find.text('Ruby Sword'), findsOneWidget);

        final backBarPosition = tester.getTopLeft(
          find.byType(ModelDetailBackBar),
        );
        final tabBarPosition = tester.getTopLeft(find.byType(TabBar));
        expect(backBarPosition.dy, lessThan(tabBarPosition.dy));

        final tabBar = tester.widget<TabBar>(find.byType(TabBar));
        expect(
          tabBar.tabs.map((tab) => (tab as Tab).text),
          ['General', 'Meta', 'Enchantments', 'Lore'],
        );
      },
    );

    testWidgets('wires the tab views to General, Meta, Enchantments and Lore pages', (
      tester,
    ) async {
      await pumpPage(tester);

      final tabBarView = tester.widget<TabBarView>(find.byType(TabBarView));
      expect(tabBarView.children.map((w) => w.runtimeType), [
        ItemGeneralPage,
        ItemMetaPage,
        ItemEnchantmentPage,
        LorePage,
      ]);
    });

    testWidgets('tapping back navigates to the item list', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('model_detail_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('Item List'), findsOneWidget);
    });
  });
}
