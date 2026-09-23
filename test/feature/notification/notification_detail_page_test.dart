import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/notification/notification_detail_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('NotificationDetailPage', () {
    const selected = NotificationModel(
      id: 'notif-1',
      uiName: 'Level Up',
      material: 'minecraft:diamond',
    );

    Future<void> pumpPage(WidgetTester tester) async {
      final store = Store<AppState>(
        initialState: const AppState(selectedNotification: selected),
      );

      final router = GoRouter(
        initialLocation: '/notifications/detail',
        routes: [
          GoRoute(
            path: '/notifications',
            builder: (context, state) =>
                const Scaffold(body: Text('Notification List')),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) => const NotificationDetailPage(),
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

    testWidgets('shows a back bar with the selected notification name', (tester) async {
      await pumpPage(tester);

      expect(find.byType(PageHeader), findsOneWidget);
      expect(find.text('Level Up'), findsOneWidget);
    });

    testWidgets('shows the notification edit form below the back bar', (tester) async {
      await pumpPage(tester);

      expect(find.text('minecraft:diamond'), findsOneWidget);
    });

    testWidgets('tapping back navigates to the notification list', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('page_header_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('Notification List'), findsOneWidget);
    });

    testWidgets('shows info, delete and save in the header', (tester) async {
      await pumpPage(tester);

      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}
