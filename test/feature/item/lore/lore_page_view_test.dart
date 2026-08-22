import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/factory/item/item_lore_view_state.dart';
import 'package:stelaris/feature/item/lore/lore_page_view.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('LorePageView Widget Tests', () {
    ItemLoreView buildView(List<ItemLoreDto> lore) {
      return ItemLoreView(
        selected: ItemModel(
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

    testWidgets('renders a tile for every lore line', (tester) async {
      final view = buildView([
        const ItemLoreDto(id: '1', text: 'First line'),
        const ItemLoreDto(id: '2', text: 'Second line'),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: LorePageView(view: view)),
        ),
      );

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

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: LorePageView(view: view)),
        ),
      );

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

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: LorePageView(view: view)),
        ),
      );

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

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: LorePageView(view: view)),
        ),
      );

      final list = tester.widget<ReorderableListView>(
        find.byType(ReorderableListView),
      );

      // Flutter never actually calls back with an index this far out of
      // range, but the callback still guards against it defensively.
      expect(() => list.onReorderItem!(0, 99), returnsNormally);
    });
  });
}
