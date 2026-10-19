import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/edit_card/edit_card.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/advancement/advancement_detail_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/util/component_context.dart';

import '../../support/edit_card.dart';

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

    /// The card labelled [label].
    Finder cardOf(String label) => find.widgetWithText(EditCard, label);

    testWidgets('the title keeps digits, punctuation and umlauts', (
      tester,
    ) async {
      await pumpPage(tester);

      await editCard(tester, 'Title', 'Level 5 – Glückwunsch!');

      expect(
        store.state.selectedAdvancement?.title,
        '"Level 5 – Glückwunsch!"',
      );
    });

    testWidgets('the description is stored as a text component', (
      tester,
    ) async {
      await pumpPage(tester);

      await editCard(tester, 'Description', 'Defeat a mob');

      expect(store.state.selectedAdvancement?.description, '"Defeat a mob"');
      expect(store.state.unsavedChanges, NavigationEntry.advancements);
    });

    testWidgets('formatting in the title is stored as json', (tester) async {
      await pumpPage(tester);

      await editCard(tester, 'Title', '<gold>First <b>Kill');

      expect(jsonDecode(store.state.selectedAdvancement!.title!), {
        'text': '',
        'extra': [
          {'text': 'First ', 'color': 'gold'},
          {'text': 'Kill', 'color': 'gold', 'bold': true},
        ],
      });
    });

    testWidgets('a stored title shows with its formatting', (tester) async {
      await pumpPage(
        tester,
        initialState: AppState(
          selectedAdvancement: selected.copyWith(
            title: '{"text":"First Kill","color":"gold"}',
            description: 'Plain from before',
          ),
        ),
      );

      final title = tester.widget<ComponentPreview>(
        find.descendant(
          of: cardOf('Title'),
          matching: find.byType(ComponentPreview),
        ),
      );
      expect(title.text, '<gold>First Kill');
      // Stored as plain text before the editor, still shown as it was.
      expect(
        find.descendant(
          of: cardOf('Description'),
          matching: find.text('Plain from before', findRichText: true),
        ),
        findsOneWidget,
      );
    });

    testWidgets('an emptied title is removed', (tester) async {
      await pumpPage(
        tester,
        initialState: AppState(
          selectedAdvancement: selected.copyWith(title: '"Old"'),
        ),
      );

      await editCard(tester, 'Title', '');

      expect(store.state.selectedAdvancement?.title, isNull);
    });

    testWidgets('an unset title shows the placeholder in its preview', (
      tester,
    ) async {
      await pumpPage(tester);

      expect(
        find.descendant(
          of: find.descendant(
            of: cardOf('Title'),
            matching: find.byType(ComponentPreview),
          ),
          matching: find.text('Not set'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('each axis of the position has its own hint', (tester) async {
      await pumpPage(tester);

      expect(
        find.text('The horizontal position in the advancement tree'),
        findsOneWidget,
      );
      expect(
        find.text('The vertical position in the advancement tree'),
        findsOneWidget,
      );
    });

    testWidgets('a whole position shows without a fraction', (tester) async {
      await pumpPage(
        tester,
        initialState: AppState(
          selectedAdvancement: selected.copyWith(x: 2, y: 1.5),
        ),
      );

      expect(
        find.descendant(of: cardOf('Position X'), matching: find.text('2')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: cardOf('Position Y'), matching: find.text('1.5')),
        findsOneWidget,
      );
    });

    testWidgets('a position that is no number is not saved', (tester) async {
      await pumpPage(
        tester,
        initialState: AppState(selectedAdvancement: selected.copyWith(x: 3)),
      );

      await editCard(tester, 'Position X', '-');

      expect(find.text('Please enter a valid number'), findsOneWidget);
      expect(store.state.selectedAdvancement?.x, 3);
    });

    testWidgets('an invalid background is not saved', (tester) async {
      await pumpPage(tester);

      await editCard(tester, 'Background', 'Stone Wall');

      expect(
        find.text(
          'Invalid texture path '
          '(e.g. "minecraft:gui/advancements/backgrounds/stone")',
        ),
        findsOneWidget,
      );
      expect(store.state.selectedAdvancement?.background, isNull);
    });

    testWidgets('choosing a parent removes the background', (tester) async {
      const root = AdvancementModel(id: 'root', uiName: 'Root');
      await pumpPage(
        tester,
        initialState: AppState(
          selectedAdvancement: selected.copyWith(
            background: 'minecraft:gui/advancements/backgrounds/stone',
          ),
          advancements: const PaginatedResult(
            items: [root, selected],
            totalItems: 2,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      await tester.ensureVisible(cardOf('Parent'));
      await tester.tap(cardOf('Parent'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Root'));
      await tester.pumpAndSettle();

      final advancement = store.state.selectedAdvancement!;
      expect(advancement.parentId, 'root');
      expect(advancement.background, isNull);
    });

    testWidgets('the description takes the color of the frame', (tester) async {
      ComponentContext contextOf() => tester
          .widget<ComponentPreview>(
            find.descendant(
              of: cardOf('Description'),
              matching: find.byType(ComponentPreview),
            ),
          )
          .componentContext;

      await pumpPage(
        tester,
        initialState: AppState(
          selectedAdvancement: selected.copyWith(description: '"Win"'),
        ),
      );
      expect(contextOf(), ComponentContext.advancementDescription);

      await tester.ensureVisible(cardOf('Frame type'));
      await tester.tap(cardOf('Frame type'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Challenge'));
      await tester.pumpAndSettle();

      expect(contextOf(), ComponentContext.challengeDescription);
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

      await tester.ensureVisible(cardOf('Parent'));
      await tester.tap(cardOf('Parent'));
      await tester.pumpAndSettle();

      final options = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(ListTile),
      );
      expect(find.widgetWithText(ListTile, 'Root'), findsOneWidget);
      expect(
        find.descendant(of: options, matching: find.text('Child')),
        findsNothing,
      );
      expect(
        find.descendant(of: options, matching: find.text('Grand Child')),
        findsNothing,
      );

      await tester.tap(find.widgetWithText(ListTile, 'Root'));
      await tester.pumpAndSettle();

      expect(store.state.selectedAdvancement?.parentId, 'root');
    });

    testWidgets('the material accepts keys longer than 30 characters', (
      tester,
    ) async {
      const key = 'minecraft:light_blue_glazed_terracotta';
      await pumpPage(tester);

      await editCard(tester, 'Material', key);

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
