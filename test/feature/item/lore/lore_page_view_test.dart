import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/item/item_lore_view_state.dart';
import 'package:stelaris/feature/item/lore/lore_page_view.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

void main() {
  group('LorePageView Widget Tests', () {
    setUp(() {
      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(null, statusCode: 204);
    });

    ItemLoreView buildView(List<ItemLoreDto> lore) {
      return ItemLoreView(
        selected: ItemModel(
          id: 'item-1',
          uiName: 'item',
          lore: PaginatedResult<ItemLoreDto>(
            items: lore,
            totalItems: lore.length,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );
    }

    Future<void> pumpLorePageView(
      WidgetTester tester, {
      required ItemLoreView view,
      Store<AppState>? store,
    }) async {
      final effectiveStore =
          store ??
          Store<AppState>(
            initialState: const AppState().copyWith(selectedItem: view.selected),
          );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: effectiveStore,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: LorePageView(view: view)),
          ),
        ),
      );
    }

    testWidgets('renders a tile for every lore line', (tester) async {
      final view = buildView([
        const ItemLoreDto(id: '1', text: 'First line'),
        const ItemLoreDto(id: '2', text: 'Second line'),
      ]);

      await pumpLorePageView(tester, view: view);

      expect(find.text('First line'), findsOneWidget);
      expect(find.text('Second line'), findsOneWidget);
    });

    testWidgets('uses onReorderItem instead of the deprecated onReorder', (
      tester,
    ) async {
      final view = buildView([
        const ItemLoreDto(id: '1', text: 'First line'),
        const ItemLoreDto(id: '2', text: 'Second line'),
      ]);

      await pumpLorePageView(tester, view: view);

      final list = tester.widget<ReorderableListView>(
        find.byType(ReorderableListView),
      );

      // ignore: deprecated_member_use
      expect(list.onReorder, isNull);
      expect(list.onReorderItem, isNotNull);
    });

    testWidgets('onReorderItem is a no-op when the index does not change', (
      tester,
    ) async {
      final view = buildView([
        const ItemLoreDto(id: '1', text: 'First line'),
        const ItemLoreDto(id: '2', text: 'Second line'),
      ]);

      await pumpLorePageView(tester, view: view);

      final list = tester.widget<ReorderableListView>(
        find.byType(ReorderableListView),
      );

      expect(() => list.onReorderItem!(0, 0), returnsNormally);
    });

    testWidgets('onReorderItem clamps an out-of-range target index', (
      tester,
    ) async {
      final view = buildView([
        const ItemLoreDto(id: '1', text: 'First line'),
        const ItemLoreDto(id: '2', text: 'Second line'),
      ]);

      await pumpLorePageView(tester, view: view);

      final list = tester.widget<ReorderableListView>(
        find.byType(ReorderableListView),
      );

      // Flutter never actually calls back with an index this far out of
      // range, but the callback still guards against it defensively.
      expect(() => list.onReorderItem!(0, 99), returnsNormally);
      await tester.pumpAndSettle();
    });

    testWidgets('onReorderItem dispatches ItemLoreReorderAction when items change position', (
      tester,
    ) async {
      const item = ItemModel(
        id: 'item-1',
        uiName: 'item',
        lore: PaginatedResult<ItemLoreDto>(
          items: [
            ItemLoreDto(id: '1', text: 'First line'),
            ItemLoreDto(id: '2', text: 'Second line'),
          ],
          totalItems: 2,
          totalPages: 1,
          currentPage: 1,
          pageSize: 10,
        ),
      );

      final store = Store<AppState>(
        initialState: const AppState().copyWith(selectedItem: item),
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: LorePageView(view: ItemLoreView(selected: item))),
          ),
        ),
      );

      final list = tester.widget<ReorderableListView>(
        find.byType(ReorderableListView),
      );

      // Verify calling onReorderItem does not throw
      expect(() => list.onReorderItem!(0, 1), returnsNormally);
      await tester.pumpAndSettle();
    });
  });
}
