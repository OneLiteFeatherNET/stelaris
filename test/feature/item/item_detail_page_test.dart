import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_page.dart';
import 'package:stelaris/feature/item/enchantment/item_group_selector.dart';
import 'package:stelaris/feature/item/item_detail_page.dart';
import 'package:stelaris/feature/item/components/item_components_page.dart';
import 'package:stelaris/feature/item/lore/lore_page.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/recording_http_client_adapter.dart';
import '../../support/settle_requests.dart';

/// An empty page, for the fetches the tabs start.
const Map<String, Object> _emptyPage = {
  'items': <Object>[],
  'totalItems': 0,
  'totalPages': 0,
  'currentPage': 1,
  'pageSize': 5,
};

/// The fetches of the tabs, by the last segment of their path.
const List<String> _tabLists = ['components', 'enchantments', 'lore'];

/// Answers the fetches of the tabs with [_emptyPage], counting them in
/// [requests], and hands every other request to [other].
HttpClientAdapter _withEmptyLists(
  HttpClientAdapter other,
  Map<String, int> requests,
) {
  final empty = FakeHttpClientAdapter.json(_emptyPage);
  return _RoutingAdapter((options) {
    final list = options.uri.pathSegments.last;
    if (!_tabLists.contains(list)) return other;
    requests[list] = (requests[list] ?? 0) + 1;
    return empty;
  });
}

class _RoutingAdapter implements HttpClientAdapter {
  _RoutingAdapter(this._route);

  final HttpClientAdapter Function(RequestOptions options) _route;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _route(options).fetch(options, requestStream, cancelFuture);

  @override
  void close({bool force = false}) {}
}

void main() {
  group('ItemDetailPage', () {
    const selected = ItemModel(id: 'item-1', uiName: 'Ruby Sword');

    late Store<AppState> store;

    /// The fetches of the tabs so far, see [_withEmptyLists].
    late Map<String, int> requests;

    /// Whether the shown tab still waits for its data.
    bool showsPlaceholders() => [
      'component_skeleton',
      'enchantment_skeleton',
      'lore_skeleton',
    ].any((key) => find.byKey(Key(key)).evaluate().isNotEmpty);

    Future<void> pumpPage(
      WidgetTester tester, {
      String location = '/items/detail',
      HttpClientAdapter? adapter,
    }) async {
      requests = {};
      ApiService().itemApi.apiClient.dio.httpClientAdapter = _withEmptyLists(
        adapter ?? RecordingHttpClientAdapter({}),
        requests,
      );
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
                // The app shows detail pages inside BasePage's Scaffold.
                builder: (context, state) =>
                    const Scaffold(body: ItemDetailPage()),
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
      // Components, the tab the page opens on, loads right away.
      await settleRequests(tester, showsPlaceholders);
    }

    testWidgets('shows the back arrow with the item name above the tabs', (
      tester,
    ) async {
      await pumpPage(tester);

      // The Components tab has a PageHeader of its own.
      final header = find.ancestor(
        of: find.byKey(const Key('page_header_back_button')),
        matching: find.byType(PageHeader),
      );
      expect(header, findsOneWidget);
      expect(find.text('Ruby Sword'), findsOneWidget);

      final backBarPosition = tester.getTopLeft(header);
      final tabBarPosition = tester.getTopLeft(find.byType(TabBar));
      expect(backBarPosition.dy, lessThan(tabBarPosition.dy));

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.tabs.map((tab) => (tab as Tab).text), [
        'Components',
        'Enchantments',
        'Lore',
      ]);
    });

    testWidgets('opens on Components', (tester) async {
      await pumpPage(tester);

      expect(
        DefaultTabController.of(tester.element(find.byType(TabBar))).index,
        0,
      );
      expect(find.byType(ItemComponentsPage), findsOneWidget);
    });

    testWidgets(
      'wires the tab views to Components, Enchantments and Lore pages',
      (tester) async {
        await pumpPage(tester);

        final tabBarView = tester.widget<TabBarView>(find.byType(TabBarView));
        expect(tabBarView.children.map((w) => w.runtimeType), [
          ItemComponentsPage,
          ItemEnchantmentPage,
          LorePage,
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

    Future<void> openEnchantments(WidgetTester tester) async {
      await tester.tap(find.widgetWithText(Tab, 'Enchantments'));
      // The tab shows its data once it loaded and stands still.
      await settleRequests(tester, showsPlaceholders);
    }

    for (final (tab, skeleton) in [
      ('Enchantments', 'enchantment_skeleton'),
      ('Lore', 'lore_skeleton'),
    ]) {
      testWidgets('$tab shows placeholders until it loaded', (tester) async {
        await pumpPage(tester);

        await tester.tap(find.widgetWithText(Tab, tab));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byKey(Key(skeleton)), findsOneWidget);

        await settleRequests(tester, showsPlaceholders);
        expect(find.byKey(Key(skeleton)), findsNothing);
      });
    }

    testWidgets('each tab loads once, not again when swiping back', (
      tester,
    ) async {
      await pumpPage(tester);
      expect(requests, {'components': 1});

      await openEnchantments(tester);
      await tester.tap(find.widgetWithText(Tab, 'Lore'));
      await settleRequests(tester, showsPlaceholders);
      await openEnchantments(tester);
      await tester.tap(find.widgetWithText(Tab, 'Components'));
      await tester.pumpAndSettle();

      // Back on tabs which already loaded: no further requests.
      expect(requests, {'components': 1, 'enchantments': 1, 'lore': 1});
    });

    /// Changes the group next to the add button on the Enchantments tab,
    /// and confirms that the enchantments are reset.
    Future<void> chooseArmorGroup(WidgetTester tester) async {
      await openEnchantments(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(ItemGroupSelector),
          matching: find.text('Meta'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Armor').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
    }

    testWidgets('the group sits next to the add button on Enchantments', (
      tester,
    ) async {
      await pumpPage(tester);
      await openEnchantments(tester);
      final enchantments = find.byType(ItemEnchantmentPage);
      expect(
        find.descendant(
          of: enchantments,
          matching: find.byType(ItemGroupSelector),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: enchantments, matching: find.text('Add')),
        findsOneWidget,
      );
    });

    testWidgets('cancelling a group change keeps the group', (tester) async {
      await pumpPage(tester);
      await openEnchantments(tester);

      await tester.tap(find.text('Meta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Armor').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(store.state.selectedItem!.groupName, EnchantmentGroup.meta);
      expect(store.state.unsavedChanges, isNull);
      expect(find.text('Meta'), findsOneWidget);
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
      await pumpPage(tester, adapter: adapter);

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
      await pumpPage(
        tester,
        adapter: RecordingHttpClientAdapter({
          'id': 'item-1',
          'uiName': 'Ruby Sword',
        }),
      );

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

    for (final former in ['general', 'meta']) {
      testWidgets('an old ?tab=$former link opens on Enchantments', (
        tester,
      ) async {
        await pumpPage(tester, location: '/items/detail?tab=$former');

        expect(
          DefaultTabController.of(tester.element(find.byType(TabBar))).index,
          1,
        );
      });
    }
  });
}
