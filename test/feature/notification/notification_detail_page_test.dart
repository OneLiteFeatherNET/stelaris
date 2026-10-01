import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';
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

    late Store<AppState> store;

    Future<void> pumpPage(WidgetTester tester) async {
      store = Store<AppState>(
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
        store.state.selectedNotification?.title,
        'Level 5 – Glückwunsch!',
      );
    });

    testWidgets('leaving the page clears the selection', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('page_header_back_button')));
      await tester.pumpAndSettle();

      expect(store.state.selectedNotification, isNull);
    });
  });
}
