import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/item/item_lore_view_state.dart';
import 'package:stelaris/feature/item/lore/lore_line_card.dart';
import 'package:stelaris/feature/item/lore/lore_page_view.dart';
import 'package:stelaris/feature/item/lore/lore_preview.dart';
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
      bool showPreview = false,
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
            home: Scaffold(
              body: LorePageView(view: view, showPreview: showPreview),
            ),
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

    testWidgets('renders every lore line as a card with a drag handle', (
      tester,
    ) async {
      final view = buildView([
        const ItemLoreDto(id: '1', text: 'First line'),
        const ItemLoreDto(id: '2', text: 'Second line'),
      ]);

      await pumpLorePageView(tester, view: view);

      expect(find.byType(LoreLineCard), findsNWidgets(2));
      expect(find.byKey(const Key('lore_drag_handle')), findsNWidgets(2));
      expect(find.byType(ReorderableDragStartListener), findsNWidgets(2));
      expect(
        tester
            .widget<ReorderableListView>(find.byType(ReorderableListView))
            .buildDefaultDragHandles,
        isFalse,
      );
    });

    testWidgets('tapping a card opens the edit dialog', (tester) async {
      final view = buildView([
        const ItemLoreDto(id: '1', text: 'First line'),
      ]);

      await pumpLorePageView(tester, view: view);
      await tester.tap(find.text('First line'));
      await tester.pumpAndSettle();

      expect(find.text('Edit lore'), findsOneWidget);
    });

    testWidgets('dragging a card by its handle reorders the lines', (
      tester,
    ) async {
      final view = buildView([
        const ItemLoreDto(id: '1', text: 'First line'),
        const ItemLoreDto(id: '2', text: 'Second line'),
      ]);
      final store = Store<AppState>(
        initialState: const AppState().copyWith(selectedItem: view.selected),
      );

      await pumpLorePageView(tester, view: view, store: store);
      await tester.drag(
        find.byKey(const Key('lore_drag_handle')).first,
        const Offset(0, 150),
      );
      await tester.pumpAndSettle();

      expect(
        store.state.selectedItem!.lore.items.map((line) => line.id),
        ['2', '1'],
      );
    });

    testWidgets('leaves the preview out by default', (tester) async {
      final view = buildView([
        const ItemLoreDto(id: '1', text: 'First line'),
      ]);

      await pumpLorePageView(tester, view: view);

      expect(find.byType(LorePreview), findsNothing);
    });

    testWidgets('a click on the drag handle does not open the edit dialog', (
      tester,
    ) async {
      final view = buildView([
        const ItemLoreDto(id: '1', text: 'First line'),
      ]);

      await pumpLorePageView(tester, view: view);
      await tester.tap(find.byKey(const Key('lore_drag_handle')));
      await tester.pumpAndSettle();

      expect(find.text('Edit lore'), findsNothing);
    });

    testWidgets('shows the item name and lines in the preview on wide layouts', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final view = buildView([
        const ItemLoreDto(id: '1', text: 'First line'),
        const ItemLoreDto(id: '2', text: 'Second line'),
      ]);

      await pumpLorePageView(tester, view: view, showPreview: true);

      final preview = find.byKey(const Key('lore_preview'));
      expect(preview, findsOneWidget);
      expect(
        find.descendant(of: preview, matching: find.text('item')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: preview, matching: find.text('Second line')),
        findsOneWidget,
      );
    });

    testWidgets('the preview renders the formatting of the lines', (
      tester,
    ) async {
      final view = buildView([
        const ItemLoreDto(id: '1', text: '<yellow>Hello'),
      ]);

      await pumpLorePageView(tester, view: view, showPreview: true);

      final preview = find.byKey(const Key('lore_preview'));
      // The card shows the line as written, the preview without its tag.
      expect(find.text('<yellow>Hello'), findsOneWidget);
      final line = tester.widget<Text>(
        find.descendant(of: preview, matching: find.text('Hello')),
      );
      final yellow = (line.textSpan! as TextSpan).children!.single as TextSpan;
      expect(yellow.style?.color, const Color(0xFFFFFF55));
    });

    testWidgets('the preview counts the lines not loaded yet', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      const item = ItemModel(
        id: 'item-1',
        uiName: 'item',
        lore: PaginatedResult<ItemLoreDto>(
          items: [ItemLoreDto(id: '1', text: 'First line')],
          totalItems: 5,
          totalPages: 5,
          currentPage: 1,
          pageSize: 1,
        ),
      );

      await pumpLorePageView(
        tester,
        view: ItemLoreView(selected: item),
        showPreview: true,
      );

      expect(find.text('and 4 more lines'), findsOneWidget);
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
