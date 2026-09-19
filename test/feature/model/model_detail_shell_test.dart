import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/model/model_detail_back_bar.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  group('ModelDetailShell', () {
    Widget createWidget({required Widget body, String? title}) {
      final router = GoRouter(
        initialLocation: '/items/detail',
        routes: [
          GoRoute(
            path: '/items',
            builder: (context, state) => const Scaffold(body: Text('Item List')),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) => Scaffold(
                  body: ModelDetailShell(
                    parentRoute: '/items',
                    title: title,
                    body: body,
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

    testWidgets('shows the back bar with the given title above the body', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(title: 'Ruby Sword', body: const Text('Body content')),
      );

      expect(find.byType(ModelDetailBackBar), findsOneWidget);
      expect(find.text('Ruby Sword'), findsOneWidget);
      expect(find.text('Body content'), findsOneWidget);

      final backBarPosition = tester.getTopLeft(find.byType(ModelDetailBackBar));
      final bodyPosition = tester.getTopLeft(find.text('Body content'));
      expect(backBarPosition.dy, lessThan(bodyPosition.dy));
    });

    testWidgets('renders without a title when none is given', (tester) async {
      await tester.pumpWidget(createWidget(body: const Text('Body content')));

      expect(find.byType(ModelDetailBackBar), findsOneWidget);
      expect(find.text('Body content'), findsOneWidget);
    });

    testWidgets('tapping back navigates to parentRoute', (tester) async {
      await tester.pumpWidget(
        createWidget(title: 'Ruby Sword', body: const Text('Body content')),
      );

      await tester.tap(find.byKey(const Key('model_detail_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('Item List'), findsOneWidget);
    });
  });
}
