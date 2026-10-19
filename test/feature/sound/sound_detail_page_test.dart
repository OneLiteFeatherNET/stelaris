import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/sound/sound_detail_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/edit_card.dart';

void main() {
  group('SoundDetailPage', () {
    final selected = SoundEventModel(id: 'sound-1', uiName: 'Ding');

    late Store<AppState> store;


    Future<void> pumpPage(WidgetTester tester) async {
      store = Store<AppState>(
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

    testWidgets('the key keeps its dots and the subtitle its spaces', (
      tester,
    ) async {
      await pumpPage(tester);

      await editCard(tester, 'Key', 'entity.player.hurt');
      await editCard(tester, 'Subtitle', 'Player hurt');

      expect(store.state.selectedSoundEvent?.keyName, 'entity.player.hurt');
      expect(store.state.selectedSoundEvent?.subTitle, 'Player hurt');
    });
  });
}
