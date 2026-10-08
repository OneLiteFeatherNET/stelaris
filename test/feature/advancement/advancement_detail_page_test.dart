import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/advancement/advancement_detail_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('AdvancementDetailPage', () {
    const selected = AdvancementModel(
      id: 'notif-1',
      uiName: 'Level Up',
      material: 'minecraft:diamond',
    );

    late Store<AppState> store;

    Future<void> pumpPage(
      WidgetTester tester, {
      AppState initialState = const AppState(selectedAdvancement: selected),
    }) async {
      store = Store<AppState>(initialState: initialState);

      final router = GoRouter(
        initialLocation: '/advancements/detail',
        routes: [
          GoRoute(
            path: '/advancements',
            builder: (context, state) =>
                const Scaffold(body: Text('Advancement List')),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) => const AdvancementDetailPage(),
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

    testWidgets('shows a back bar with the selected advancement name', (
      tester,
    ) async {
      await pumpPage(tester);

      expect(find.byType(PageHeader), findsOneWidget);
      expect(find.text('Level Up'), findsOneWidget);
    });

    testWidgets('shows the advancement edit form below the back bar', (
      tester,
    ) async {
      await pumpPage(tester);

      expect(find.text('minecraft:diamond'), findsOneWidget);
    });

    testWidgets('tapping back navigates to the advancement list', (
      tester,
    ) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('page_header_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('Advancement List'), findsOneWidget);
    });

    /// The text field of the card labelled [label].
    Finder fieldOf(String label) => find.descendant(
      of: find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((w) => w is TextInputCard),
      ),
      matching: find.byType(TextFormField),
    );

    Future<void> enterAndBlur(
      WidgetTester tester,
      String label,
      String text,
    ) async {
      await tester.enterText(fieldOf(label), text);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    }

    testWidgets('the title keeps digits, punctuation and umlauts', (
      tester,
    ) async {
      await pumpPage(tester);

      await enterAndBlur(tester, 'Title', 'Level 5 – Glückwunsch!');

      expect(
        store.state.selectedAdvancement?.title,
        '"Level 5 – Glückwunsch!"',
      );
    });

    testWidgets('the description is stored as a text component', (
      tester,
    ) async {
      await pumpPage(tester);

      await enterAndBlur(tester, 'Description', 'Defeat a mob');

      expect(store.state.selectedAdvancement?.description, '"Defeat a mob"');
    });

    testWidgets('the display segments toggle the flags', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('Hidden'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show toast'));
      await tester.pumpAndSettle();

      final advancement = store.state.selectedAdvancement!;
      expect(advancement.hidden, isTrue);
      expect(advancement.showToast, isNot(selected.showToast));
      expect(store.state.unsavedChanges, NavigationEntry.advancements);
    });

    testWidgets('the background is only shown for a root advancement', (
      tester,
    ) async {
      await pumpPage(
        tester,
        initialState: AppState(
          selectedAdvancement: selected.copyWith(parentId: 'root'),
        ),
      );

      expect(find.text('Background'), findsNothing);
    });

    testWidgets('the parent can be neither itself nor a descendant', (
      tester,
    ) async {
      const root = AdvancementModel(id: 'root', uiName: 'Root');
      const child = AdvancementModel(
        id: 'child',
        uiName: 'Child',
        parentId: 'notif-1',
      );
      const grandChild = AdvancementModel(
        id: 'grand-child',
        uiName: 'Grand Child',
        parentId: 'child',
      );
      await pumpPage(
        tester,
        initialState: const AppState(
          selectedAdvancement: selected,
          advancements: PaginatedResult(
            items: [root, selected, child, grandChild],
            totalItems: 4,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      expect(find.text('Root'), findsWidgets);
      expect(find.text('Child'), findsNothing);
      expect(find.text('Grand Child'), findsNothing);

      await tester.tap(find.text('Root').last);
      await tester.pumpAndSettle();

      expect(store.state.selectedAdvancement?.parentId, 'root');
    });

    testWidgets('the material accepts keys longer than 30 characters', (
      tester,
    ) async {
      const key = 'minecraft:light_blue_glazed_terracotta';
      await pumpPage(tester);

      await enterAndBlur(tester, 'Material', key);

      expect(store.state.selectedAdvancement?.material, key);
    });

    testWidgets('leaving the page clears the selection', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('page_header_back_button')));
      await tester.pumpAndSettle();

      expect(store.state.selectedAdvancement, isNull);
    });
  });
}
