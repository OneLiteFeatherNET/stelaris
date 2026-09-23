import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/font/chars/font_char_page.dart';
import 'package:stelaris/feature/font/face/font_face_page.dart';
import 'package:stelaris/feature/font/font_detail_page.dart';
import 'package:stelaris/feature/font/font_general_page.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('FontDetailPage', () {
    const selected = FontModel(id: 'font-1', uiName: 'Roboto Mono');

    Future<void> pumpPage(WidgetTester tester) async {
      final store = Store<AppState>(
        initialState: const AppState(selectedFont: selected),
      );

      final router = GoRouter(
        initialLocation: '/fonts/detail',
        routes: [
          GoRoute(
            path: '/fonts',
            builder: (context, state) => const Scaffold(body: Text('Font List')),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) => const FontDetailPage(),
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
      'shows the back arrow with the font name above the tabs',
      (tester) async {
        await pumpPage(tester);

        expect(find.byType(PageHeader), findsOneWidget);
        expect(find.text('Roboto Mono'), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);

        final backBarPosition = tester.getTopLeft(
          find.byType(PageHeader),
        );
        final tabBarPosition = tester.getTopLeft(find.byType(TabBar));
        expect(backBarPosition.dy, lessThan(tabBarPosition.dy));

        expect(find.text('General'), findsOneWidget);
        expect(find.text('FontFace'), findsOneWidget);
        expect(find.text('Chars'), findsOneWidget);
      },
    );

    testWidgets('wires the tab views to General, FontFace and Chars pages', (tester) async {
      await pumpPage(tester);

      final tabBarView = tester.widget<TabBarView>(find.byType(TabBarView));
      expect(tabBarView.children.map((w) => w.runtimeType), [
        FontGeneralPage,
        FontFacePage,
        FontCharPage,
      ]);
    });

    testWidgets('tapping back navigates to the font list', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('page_header_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('Font List'), findsOneWidget);
    });
  });
}
