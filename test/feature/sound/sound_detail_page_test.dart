import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/sound/sound_detail_page.dart';
import 'package:stelaris/feature/sound/sound_file_entries.dart';
import 'package:stelaris/feature/sound/sound_general_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('SoundDetailPage', () {
    final selected = SoundEventModel(id: 'sound-1', uiName: 'Ding');

    Future<void> pumpPage(WidgetTester tester) async {
      final store = Store<AppState>(
        initialState: AppState(selectedSoundEvent: selected),
      );

      final router = GoRouter(
        initialLocation: '/sound/detail',
        routes: [
          GoRoute(
            path: '/sound',
            builder: (context, state) => const Scaffold(body: Text('Sound List')),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) => const SoundDetailPage(),
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
      'shows the back arrow with the sound event name above the tabs',
      (tester) async {
        await pumpPage(tester);

        expect(find.byType(PageHeader), findsOneWidget);
        expect(find.text('Ding'), findsOneWidget);

        final backBarPosition = tester.getTopLeft(
          find.byType(PageHeader),
        );
        final tabBarPosition = tester.getTopLeft(find.byType(TabBar));
        expect(backBarPosition.dy, lessThan(tabBarPosition.dy));

        expect(find.text('General'), findsOneWidget);
        expect(find.text('Entries'), findsOneWidget);
      },
    );

    testWidgets('wires the tab views to General and Entries pages', (tester) async {
      await pumpPage(tester);

      final tabBarView = tester.widget<TabBarView>(find.byType(TabBarView));
      expect(tabBarView.children.map((w) => w.runtimeType), [
        SoundGeneralPage,
        SoundFileEntryPage,
      ]);
    });

    testWidgets('tapping back navigates to the sound list', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('page_header_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('Sound List'), findsOneWidget);
    });
  });
}
