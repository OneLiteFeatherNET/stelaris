import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/blockstate/block_state_detail_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('BlockStateDetailPage', () {
    const selected = BlockStateModel(
      id: 'b1',
      uiName: 'Footprints',
      key: 'minecraft:pink_petals',
      rules: [BlockStateRule(name: 'Seat', model: 'minecraft:block/seat')],
    );

    late Store<AppState> store;

    Future<void> pumpPage(WidgetTester tester) async {
      // Wide enough for the header's actions to keep their labels.
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      store = Store<AppState>(
        initialState: const AppState(
          selectedBlockState: selected,
          blockStates: PaginatedResult<BlockStateModel>(
            items: [selected],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );
      final router = GoRouter(
        initialLocation: '/blockstates/detail',
        routes: [
          GoRoute(
            path: '/blockstates',
            builder: (context, state) =>
                const Scaffold(body: Text('Blockstate List')),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) => const BlockStateDetailPage(),
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

    testWidgets('shows the name as the title and the rules below', (
      tester,
    ) async {
      await pumpPage(tester);

      expect(find.text('Footprints'), findsOneWidget);
      expect(find.text('Seat'), findsOneWidget);
    });

    testWidgets('an added rule is staged until the save', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('Add rule'));
      await tester.pumpAndSettle();
      // The dialog's save, the header has one as well.
      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('Save')),
      );
      await tester.pumpAndSettle();

      expect(store.state.selectedBlockState!.rules, hasLength(2));
      expect(store.state.unsavedChanges, NavigationEntry.blockstates);
      // The list keeps what is saved.
      expect(store.state.blockStates.items.single.rules, hasLength(1));
    });

    testWidgets('leaving the page clears the selection', (tester) async {
      await pumpPage(tester);

      GoRouter.of(tester.element(find.byType(BlockStateDetailPage)))
          .go('/blockstates');
      await tester.pumpAndSettle();

      expect(store.state.selectedBlockState, isNull);
    });
  });
}
