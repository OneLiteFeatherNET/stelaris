import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/model/model_detail_back_bar.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  group('ModelDetailBackBar', () {
    Widget createWidget({String? title}) {
      final router = GoRouter(
        initialLocation: '/items/detail',
        routes: [
          GoRoute(
            path: '/items',
            builder: (context, state) => const Scaffold(body: Text('Items')),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) => Scaffold(
                  body: ModelDetailBackBar(
                    parentRoute: '/items',
                    title: title,
                  ),
                ),
              ),
            ],
          ),
        ],
      );

      return MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
    }

    testWidgets('renders a back arrow icon', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders the optional title next to the arrow', (tester) async {
      await tester.pumpWidget(createWidget(title: 'Ruby Sword'));
      await tester.pumpAndSettle();

      expect(find.text('Ruby Sword'), findsOneWidget);
    });

    testWidgets('navigates to parentRoute when the arrow is tapped', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('model_detail_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('Items'), findsOneWidget);
    });
  });
}
